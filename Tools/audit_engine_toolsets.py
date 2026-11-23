#!/usr/bin/env python3
"""Audit the UE6 engine's official MCP Toolsets and emit a reproducible inventory.

Zero third-party dependencies: the emitter writes YAML 1.2 scalars using JSON
double-quoted strings, which PyYAML (and the project's UEYaml adapter) can read.
The host project deliberately keeps `Tools/` standard-library-only.

Usage:
    python Tools/audit_engine_toolsets.py                   # regenerate the inventory
    python Tools/audit_engine_toolsets.py --check           # drift gate, exits 1 on drift
    python Tools/audit_engine_toolsets.py --check-enablement
        # verify that every plugin enabled in Ann.uproject resolves, and that its
        # transitive `Plugins` dependency closure has no missing hard references.
    python Tools/audit_engine_toolsets.py --engine D:/path/to/AnnUnrealEngine
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from collections import Counter
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_ENGINE = PROJECT_ROOT.parent / "AnnUnrealEngine"
INVENTORY = PROJECT_ROOT / "Docs" / "ai-capabilities" / "toolset-inventory.yaml"

# UE toolsets declare AI-callable functions via UFUNCTION metadata. The engine
# uses both `UFUNCTION(meta = (...))` and `UFUNCTION(BlueprintCallable, meta =
# (...), Category = ...)`, so the macro arguments must be brace-matched rather
# than captured with a first-')' regex.
UFUNCTION_START = re.compile(r"\bUFUNCTION\s*\(")
META_START = re.compile(r"\bmeta\s*=\s*\(")
ACCESS_MODE = re.compile(r'AIAccessMode\s*=\s*"(\w+)"')
# First identifier immediately followed by '(' after the macro is the function name.
FUNCTION_NAME = re.compile(r"\b([A-Za-z_]\w*)\s*\(")
CALLABLE_TAGS = ("AICallable", "AIRuntimeCallable")


def q(value: str) -> str:
    """JSON double-quoted string; also a valid YAML 1.2 double-quoted scalar."""
    return json.dumps(value, ensure_ascii=False)


def load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8-sig"))


def load_relaxed_json(path: Path) -> dict:
    """UE plugin descriptors allow trailing commas; stdlib json does not."""
    text = path.read_text(encoding="utf-8-sig")
    return json.loads(re.sub(r",(\s*[}\]])", r"\1", text))


def balanced(text: str, start: int) -> tuple[str, int]:
    """Return the parenthesised content starting after '(' at `start`, and its end.

    `start` must point just past the opening parenthesis. Handles nested parens
    (e.g. meta=(..., DisplayName="Foo (Bar)") inside UFUNCTION(...)).
    """
    depth, pos = 1, start
    while pos < len(text) and depth:
        char = text[pos]
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
        pos += 1
    return text[start:pos - 1], pos


def iter_callable_meta(text: str):
    """Yield (end_of_macro, meta_content) for every AI-callable UFUNCTION."""
    for macro in UFUNCTION_START.finditer(text):
        args, end = balanced(text, macro.end())
        meta = META_START.search(args)
        if not meta:
            continue
        tag, _ = balanced(args, meta.end())
        if any(t in tag for t in CALLABLE_TAGS):
            yield end, tag


def engine_version(engine: Path) -> dict:
    version_file = engine / "Engine" / "Build" / "Build.version"
    if not version_file.is_file():
        return {"major": "?", "minor": "?", "patch": "?", "branch": "?"}
    d = load_json(version_file)
    return {
        "major": d["MajorVersion"],
        "minor": d["MinorVersion"],
        "patch": d["PatchVersion"],
        "branch": d["BranchName"],
    }


def collect(engine: Path) -> dict:
    root = engine / "Engine" / "Plugins" / "Experimental" / "Toolsets"
    if not root.is_dir():
        raise SystemExit(f"Toolsets directory not found: {root}")

    aggregator = root / "AllToolsets" / "AllToolsets.uplugin"
    in_all: set[str] = set()
    if aggregator.is_file():
        for ref in load_json(aggregator).get("Plugins", []):
            if ref.get("Enabled", False):
                in_all.add(ref["Name"])

    directories = sorted(p for p in root.iterdir() if p.is_dir())
    toolsets: list[dict] = []
    total = Counter()
    annotations = 0
    for directory in directories:
        uplugins = sorted(directory.glob("*.uplugin"))
        plugin_name = uplugins[0].stem if uplugins else ""
        tools: dict[str, dict] = {}
        for header in sorted(directory.rglob("*.h")):
            rel = header.as_posix()
            if "/Intermediate/" in rel or "/Binaries/" in rel:
                continue
            text = header.read_text(encoding="utf-8", errors="ignore")
            for macro_end, tag in iter_callable_meta(text):
                annotations += 1
                mode_match = ACCESS_MODE.search(tag)
                mode = mode_match.group(1) if mode_match else "unset"
                name_match = FUNCTION_NAME.search(text, macro_end, macro_end + 800)
                name = name_match.group(1) if name_match else "_unnamed_"
                tools.setdefault(name, {
                    "name": name,
                    "access_mode": mode,
                    "header": header.name,
                })
        ordered = sorted(tools.values(), key=lambda t: t["name"])
        by_mode = Counter(t["access_mode"] for t in ordered)
        total.update(by_mode)
        content_dir = directory / "Content"
        content_assets = (
            sum(1 for p in content_dir.rglob("*") if p.is_file())
            if content_dir.is_dir() else 0
        )
        toolsets.append({
            "name": directory.name,
            "plugin": plugin_name,
            "has_uplugin": bool(uplugins),
            "in_all_toolsets": plugin_name in in_all,
            "content_assets": content_assets,
            "tool_count": len(ordered),
            "by_access_mode": dict(sorted(by_mode.items())),
            "tools": ordered,
        })

    toolsets.sort(key=lambda t: (-t["tool_count"], t["name"]))
    e = engine_version(engine)
    return {
        "engine": e,
        "toolsets_root": "Engine/Plugins/Experimental/Toolsets",
        "aggregator": "AllToolsets",
        "summary": {
            "toolset_directories": len(directories),
            "directories_with_uplugin": sum(1 for t in toolsets if t["has_uplugin"]),
            "toolsets_with_tools": sum(1 for t in toolsets if t["tool_count"]),
            "toolsets_with_content_assets": sum(1 for t in toolsets if t["content_assets"]),
            "callable_annotations": annotations,
            "total_tools": sum(t["tool_count"] for t in toolsets),
            "by_access_mode": dict(sorted(total.items())),
            "aggregator_members": len(in_all),
        },
        "toolsets": toolsets,
    }


def render(data: dict) -> str:
    e, s = data["engine"], data["summary"]
    version = f"{e['major']}.{e['minor']}.{e['patch']}"
    out: list[str] = [
        "# Generated by Tools/audit_engine_toolsets.py -- do not edit by hand.",
        "# Source of truth: the UE6 engine tree, not this file.",
        "schema_version: 1",
        "engine:",
        f"  version: {q(version)}",
        f"  branch: {q(str(e['branch']))}",
        f"  toolsets_root: {q(data['toolsets_root'])}",
        f"  aggregator: {q(data['aggregator'])}",
        "summary:",
        f"  toolset_directories: {s['toolset_directories']}",
        f"  directories_with_uplugin: {s['directories_with_uplugin']}",
        f"  toolsets_with_tools: {s['toolsets_with_tools']}",
        f"  toolsets_with_content_assets: {s['toolsets_with_content_assets']}",
        f"  callable_annotations: {s['callable_annotations']}",
        f"  total_tools: {s['total_tools']}",
        f"  aggregator_members: {s['aggregator_members']}",
        "  by_access_mode:",
    ]
    for key, value in s["by_access_mode"].items():
        out.append(f"    {key}: {value}")
    out.append("toolsets:")
    for t in data["toolsets"]:
        out.extend([
            f"  - name: {q(t['name'])}",
            f"    plugin: {q(t['plugin'])}",
            f"    has_uplugin: {'true' if t['has_uplugin'] else 'false'}",
            f"    in_all_toolsets: {'true' if t['in_all_toolsets'] else 'false'}",
            f"    content_assets: {t['content_assets']}",
            f"    tool_count: {t['tool_count']}",
            "    by_access_mode:",
        ])
        for key, value in t["by_access_mode"].items():
            out.append(f"      {key}: {value}")
        if t["tools"]:
            out.append("    tools:")
            for tool in t["tools"]:
                out.append(
                    "      - {name: %s, access_mode: %s, header: %s}"
                    % (q(tool["name"]), q(tool["access_mode"]), q(tool["header"]))
                )
        else:
            out.append("    tools: []")
    return "\n".join(out) + "\n"


def check_enablement(engine: Path) -> int:
    """Resolve Ann.uproject's Editor-only plugin enablements against the engine tree."""
    uproject = PROJECT_ROOT / "Ann.uproject"
    project = load_json(uproject)
    roots = [
        ref["Name"] for ref in project.get("Plugins", [])
        if ref.get("Enabled", False)
        and ref.get("TargetAllowList") == ["Editor"]
    ]
    if not roots:
        print("FAIL: no Editor-only plugin enablements found in Ann.uproject.")
        return 1

    plugins_root = engine / "Engine" / "Plugins"
    available = {p.stem: p for p in plugins_root.rglob("*.uplugin")}
    seen: set[str] = set()
    missing_hard: list[str] = []
    missing_optional: list[str] = []
    queue = list(roots)
    while queue:
        name = queue.pop()
        if name in seen:
            continue
        seen.add(name)
        path = available.get(name)
        if path is None:
            missing_hard.append(name)
            continue
        for ref in load_relaxed_json(path).get("Plugins", []):
            dep = ref["Name"]
            if dep not in available:
                (missing_optional if ref.get("Optional", False)
                 else missing_hard).append(f"{name} -> {dep}")
                continue
            if not ref.get("Enabled", False):
                continue
            queue.append(dep)

    print(f"Editor-only enablements ({len(roots)}): {', '.join(roots)}")
    print(f"Resolved dependency closure: {len(seen)} plugins")
    print(f"Missing hard references: {len(missing_hard)}")
    print(f"Missing optional references: {len(missing_optional)}"
          + (f" ({', '.join(missing_optional[:4])})" if missing_optional else ""))
    if missing_hard:
        for item in missing_hard[:10]:
            print(f"  MISSING {item}")
        return 1
    print("OK: enablement configuration resolves against the engine tree.")
    return 0


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--engine", type=Path, default=DEFAULT_ENGINE)
    ap.add_argument("--check", action="store_true", help="fail if the inventory is stale")
    ap.add_argument("--check-enablement", action="store_true",
                    help="verify Ann.uproject plugin enablements and their dependency closure")
    args = ap.parse_args()

    if args.check_enablement:
        return check_enablement(args.engine)

    text = render(collect(args.engine))
    rel = INVENTORY.relative_to(PROJECT_ROOT).as_posix()
    if args.check:
        current = INVENTORY.read_text(encoding="utf-8") if INVENTORY.is_file() else ""
        if current != text:
            print(f"DRIFT: {rel} is stale; run `python Tools/audit_engine_toolsets.py`.")
            return 1
        print(f"OK: {rel} matches the engine tree.")
        return 0

    INVENTORY.parent.mkdir(parents=True, exist_ok=True)
    INVENTORY.write_text(text, encoding="utf-8", newline="\n")
    print(f"Wrote {rel}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
