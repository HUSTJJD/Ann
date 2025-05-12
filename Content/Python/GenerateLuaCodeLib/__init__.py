import unreal
from . import GenerateLuaCodeWBP
from . import GenerateLuaCodeBP
from . import GenerateLuaEnumUI
from . import GenerateLuaEnumAsset
import importlib

importlib.reload(GenerateLuaCodeWBP)
importlib.reload(GenerateLuaCodeBP)
importlib.reload(GenerateLuaEnumAsset)
from .GenerateLuaCodeWBP import generate_lua_code_wbp
from .GenerateLuaCodeBP import generate_lua_code_bp
from .GenerateLuaEnumUI import generate_lua_enum_ui
from .GenerateLuaEnumAsset import generate_lua_enum_asset


def generate_lua_code_for_asset(asset):
    if isinstance(asset, unreal.WidgetBlueprint):
        generate_lua_code_wbp(asset)
    elif isinstance(asset, unreal.Blueprint):
        generate_lua_code_bp(asset)
