from ast import pattern
from xml.dom.expatbuilder import theDOMImplementation
import unreal
import os
import re


def get_game_relative_path(path):
    return path.split(".")[0].split("/Game/")[1]


def get_game_absolute_path(path):
    return unreal.Paths.project_content_dir() + get_game_relative_path(path)


def get_enum_script_absolute_path(flod, enum_name):
    path = get_game_relative_path(flod) + "/Enum/" + enum_name
    content_dir = unreal.Paths.project_content_dir()
    return content_dir + "Script/" + path + ".lua"


def get_asset_script_require_path(asset):
    path = get_game_relative_path(asset.get_path_name()).replace("/", ".")
    return path


def get_asset_script_absolute_path(asset):
    path = get_game_relative_path(asset.get_path_name())
    content_dir = unreal.Paths.project_content_dir()
    return content_dir + "Script/" + path + ".lua"


def write_file(file_path, content):
    directory = os.path.dirname(file_path)
    os.makedirs(directory, exist_ok=True)
    with open(file_path, "w", encoding="utf8", newline="\n") as f:
        f.writelines(content)


def read_file(file_path):
    if not os.path.exists(file_path):
        return []
    with open(file_path, "r") as f:
        return f.readlines()


def is_exist_lua_function(content, asset_name, function_name):
    pattern = re.compile(
        "function " + asset_name + ":" + function_name + " *\\(([a-z]|[A-Z]|\\,| )*\\)"
    )
    for line in content:
        if re.match(pattern=pattern, string=line):
            return True
