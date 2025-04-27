import unreal
import os
import FunctionLib
import importlib

importlib.reload(FunctionLib)

AUTO_GENERATE_MARK_BEGIN = "--region GEN_EUI\n"
AUTO_GENERATE_MARK_END = "--endregion GEN_EUI\n"

ignore_flods = [
    "Script",
    "Python",
    "Collections",
    "Developers",
]

LOG_MARKER = "generate_lua_code_enum_ui: "


def generate_lua_enum_ui():
    flods = os.listdir(unreal.Paths.project_content_dir())
    for flod in flods:
        if flod in ignore_flods:
            continue
        window_name = []
        flod_name = f"/Game/{flod}"
        asset_paths = unreal.EditorAssetLibrary.list_assets(flod_name)
        for asset_path in asset_paths:
            asset = unreal.EditorAssetLibrary.load_asset(asset_path)
            if isinstance(asset, unreal.WidgetBlueprint):
                name = asset.get_name()
                window_name.append(f"---@field {name} string")
        window_name.sort()
        file_name = f"EUI_{flod}"
        enum_content = f"""\
{AUTO_GENERATE_MARK_BEGIN}
---@class {file_name} : BaseEnum
{''.join(window_name)}
local {file_name} = Ann.Class("{file_name}", Ann.BaseEnum)
return {file_name}\n
{AUTO_GENERATE_MARK_END}
"""
        FunctionLib.write_file(
            FunctionLib.get_enum_script_absolute_path(flod_name, file_name),
            enum_content,
        )
        unreal.log(f"{LOG_MARKER}{flod}")
