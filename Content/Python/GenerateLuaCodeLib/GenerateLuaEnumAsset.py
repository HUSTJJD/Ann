import unreal
import os
import FunctionLib
import importlib

importlib.reload(FunctionLib)

AUTO_GENERATE_MARK_BEGIN = "--region GEN_EASSET\n"
AUTO_GENERATE_MARK_END = "\t--endregion GEN_EASSET\n"

ignore_flods = [
    "Core",
    "Script",
    "Python",
    "Collections",
    "Developers",
]

LOG_MARKER = "generate_lua_code_enum_asset: "

export_asset_type = [
    (unreal.Blueprint, "_C"),
    (unreal.AnimSequence, None),
]


def get_generate_enum_asset_code(flod_name, file_name):
    asset_name_path = []
    asset_paths = unreal.EditorAssetLibrary.list_assets(flod_name)
    for asset_path in asset_paths:
        asset = unreal.EditorAssetLibrary.load_asset(asset_path)
        for asset_type, extension in export_asset_type:
            if isinstance(asset, asset_type):
                name = asset.get_name()
                path = asset.get_path_name()
                asset_name_path.append(f'\t{name} = "{path}{extension or ""}",\n')
                break
    asset_name_path.sort()
    generate = f"""\
{AUTO_GENERATE_MARK_BEGIN}
---@class {file_name}
local {file_name} = {{\n
{"".join(asset_name_path) if len(asset_name_path) > 0 else ""}\
{AUTO_GENERATE_MARK_END}"""
    return generate


def get_template_enum_asset_code(file_name):
    template = f"""\
{AUTO_GENERATE_MARK_BEGIN}
{AUTO_GENERATE_MARK_END}
\t--region {file_name}

\t--endregion {file_name}
}}\n
return {file_name}\n
"""
    return template


def get_custom_enum_asset_code(in_content):
    auto_gen_end = in_content.index(AUTO_GENERATE_MARK_END)
    if not auto_gen_end:
        unreal.log_error(LOG_MARKER + f"not found {AUTO_GENERATE_MARK_END}")
        return
    return in_content[auto_gen_end + 1 :]


def regenerate_custom_enum_asset_code(file_name, custom_code):
    end_mark = f"return {file_name}\n"
    custom_code_end = custom_code.index(end_mark)
    if not custom_code_end:
        unreal.log_error(LOG_MARKER + f"not found {end_mark}")
        return
    new_custom_code = custom_code[:custom_code_end]
    return new_custom_code


def get_enum_asset_code(flod_name, file_name, out_content: list):
    in_content = FunctionLib.read_file(
        FunctionLib.get_enum_script_absolute_path(flod_name, file_name)
    )
    if len(in_content) == 0:
        in_content = get_template_enum_asset_code(file_name).splitlines(True)
    custom_code = get_custom_enum_asset_code(in_content)
    if not custom_code:
        return False
    new_custom_code = regenerate_custom_enum_asset_code(file_name, custom_code)
    end_mark = f"return {file_name}\n"
    out_content.extend(get_generate_enum_asset_code(flod_name, file_name))
    out_content.extend(new_custom_code)
    out_content.extend([end_mark])
    return True


def generate_lua_enum_asset():
    flods = os.listdir(unreal.Paths.project_content_dir())
    for flod in flods:
        if flod in ignore_flods:
            continue
        out_content = []
        flod_name = f"/Game/{flod}"
        file_name = f"EAsset_{flod}"
        if not get_enum_asset_code(
            flod_name=flod_name, file_name=file_name, out_content=out_content
        ):
            continue
        FunctionLib.write_file(
            FunctionLib.get_enum_script_absolute_path(flod_name, file_name),
            out_content,
        )
        unreal.log(f"{LOG_MARKER}{flod}")
