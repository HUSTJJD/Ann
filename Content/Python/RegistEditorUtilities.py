import unreal
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import GenerateLuaCodeLib
import importlib

importlib.reload(GenerateLuaCodeLib)


@unreal.uclass()
class ToolMenuEntryScriptGenerateLuaCode(unreal.ToolMenuEntryScript):
    @unreal.ufunction(override=True)
    def execute(self, context):
        super(self.__class__, self).execute(context)
        selected_paths = unreal.EditorUtilityLibrary.get_selected_folder_paths()
        for path in selected_paths:
            asset_paths = unreal.EditorAssetLibrary.list_assets(
                path[path.find("/Game/") :]
            )
            for asset_path in asset_paths:
                asset = unreal.EditorAssetLibrary.load_asset(asset_path)
                GenerateLuaCodeLib.generate_lua_code_for_asset(asset)
        selected_assets = unreal.EditorUtilityLibrary.get_selected_assets()
        for asset in selected_assets:
            GenerateLuaCodeLib.generate_lua_code_for_asset(asset)
        GenerateLuaCodeLib.generate_lua_enum_ui()

    @unreal.ufunction(override=True)
    def get_label(self, context):
        super(self.__class__, self).get_label(context)
        return "GenerateLuaCode"

    @unreal.ufunction(override=True)
    def get_tool_tip(self, context):
        super(self.__class__, self).get_tool_tip(context)
        return "绑定并生成LuaCode（BP | WBP）"

    @unreal.ufunction(override=True)
    def get_check_state(self, context):
        return super(self.__class__, self).get_check_state(context)

    @unreal.ufunction(override=True)
    def get_icon(self, context):
        super(self.__class__, self).get_icon(context)
        icon = unreal.ScriptSlateIcon(
            style_set_name="EditorStyle", style_name="ContentBrowser.AssetActions.Edit"
        )
        return icon


def regist_entry_to_menu_context(menu_name, entry_name, script_object):
    tool_menus = unreal.ToolMenus.get()
    fold_menu = tool_menus.find_menu(menu_name)
    fold_menu.add_section(section_name="AnnEditor", label="Ann Editor")
    entry = unreal.ToolMenuEntry(
        name=entry_name,
        type=unreal.MultiBlockType.MENU_ENTRY,
        script_object=script_object,
    )
    fold_menu.add_menu_entry(section_name="AnnEditor", args=entry)


def regist_generate_lua_code_tools():
    entry_generate_lua_code = ToolMenuEntryScriptGenerateLuaCode()
    regist_entry_to_menu_context(
        "ContentBrowser.FolderContextMenu",
        "GenerateLuaCode",
        entry_generate_lua_code,
    )
    regist_entry_to_menu_context(
        "ContentBrowser.AssetContextMenu",
        "GenerateLuaCode",
        entry_generate_lua_code,
    )
    unreal.log("Regist GenerateLuaCode")


if __name__ == "__main__":
    unreal.log("AnnEditor Python: Regist Editor Utilities Begin!")
    regist_generate_lua_code_tools()
    unreal.log("AnnEditor Python: Regist Editor Utilities Done!")
