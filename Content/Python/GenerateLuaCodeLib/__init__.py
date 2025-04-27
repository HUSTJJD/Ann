import unreal
from . import GenerateLuaCodeWBP
from . import GenerateLuaCodeBP
from . import GenerateLuaEnumUI
import importlib
importlib.reload(GenerateLuaCodeWBP)
importlib.reload(GenerateLuaCodeBP)
importlib.reload(GenerateLuaEnumUI)
from .GenerateLuaCodeWBP import generate_lua_code_wbp
from .GenerateLuaCodeBP import generate_lua_code_bp
from .GenerateLuaEnumUI import generate_lua_enum_ui


def generate_lua_code_for_asset(asset):
    if isinstance(asset, unreal.WidgetBlueprint):
        generate_lua_code_wbp(asset)
    elif isinstance(asset, unreal.Blueprint):
        generate_lua_code_bp(asset)
