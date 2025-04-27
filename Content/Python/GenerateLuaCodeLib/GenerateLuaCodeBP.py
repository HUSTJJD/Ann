import unreal
import FunctionLib

AUTO_GENERATE_MARK_BEGIN = "--region GEN_BP\n"
AUTO_GENERATE_MARK_END = "--endregion GEN_BP\n"


LOG_MARKER = "generate_lua_code_bp: "


standard_rpc = [
    "NetServer",
    "NetClient",
    "NetMulticast",
]

unexport_props = ["DefaultSceneRoot"]

unexport_events = ["GetModuleName"]

unexport_flags = ["BlueprintCallable"]


def get_generate_bp_code(name, class_name, exprot_infos):
    props = []
    functions = []
    for exprot_info in exprot_infos:
        if exprot_info.owner_class != class_name:
            continue
        if exprot_info.name in unexport_events:
            continue
        if exprot_info.name in unexport_props:
            continue
        field = f"---@field {exprot_info.name} {exprot_info.type} {exprot_info.flag}\n"
        if exprot_info.type != "UFunction":
            props.append(field)
        else:
            functions.append(field)
    functions.sort()
    props.sort()
    props.extend(functions)
    generate = f"""\
{AUTO_GENERATE_MARK_BEGIN}
---@class {name}
{''.join(props)}\
local {name} = UnLua.Class()\n
{AUTO_GENERATE_MARK_END}"""
    return generate


def get_template_bp_code(name):
    template = f"""\
{AUTO_GENERATE_MARK_BEGIN}
{AUTO_GENERATE_MARK_END}
-- BlueprintEvent
-- function {name}:ReceiveBeginPlay()\n
-- end\n
-- BlueprintEvent
-- function {name}:ReceiveEndPlay()\n
-- end\n
-- function {name}:ReceiveTick()\n
-- end\n
return {name}
"""
    return template


def get_custom_bp_code(in_content):
    auto_gen_end = in_content.index(AUTO_GENERATE_MARK_END)
    if not auto_gen_end:
        unreal.log_error(LOG_MARKER + f"not found {AUTO_GENERATE_MARK_END}")
        return
    return in_content[auto_gen_end + 1 :]


def regenerate_custom_bp_code(name, class_name, exprot_infos, custom_code):
    end_mark = f"return {name}\n"
    custom_code_end = custom_code.index(end_mark)
    if not custom_code_end:
        unreal.log_error(LOG_MARKER + f"not found {end_mark}")
        return
    new_custom_code = custom_code[:custom_code_end]
    lua_functions = []
    for exprot_info in exprot_infos:
        if exprot_info.owner_class != class_name:
            continue
        if exprot_info.name in unexport_events:
            continue
        if exprot_info.type == "UFunction":
            if exprot_info.type in standard_rpc:
                lua_functions.append((f"{exprot_info.name}_RPC", exprot_info.flag))
            elif not exprot_info.flag in unexport_flags:
                lua_functions.append((f"{exprot_info.name}", exprot_info.flag))
    lua_functions.sort()
    for function_name, annotation in lua_functions:
        if not FunctionLib.is_exist_lua_function(
            custom_code, asset_name=name, function_name=function_name
        ):
            if annotation:
                new_custom_code.append(f"-- {annotation}\n")
            new_custom_code.append(
                f"-- function {name}:{function_name}()\n\n-- end\n\n"
            )
    return new_custom_code


def get_bp_code(blueprint, out_content: list):
    name = blueprint.get_name()
    lua_path = FunctionLib.get_asset_script_absolute_path(blueprint)
    in_content = FunctionLib.read_file(lua_path)
    class_name = blueprint.generated_class().get_name()
    exprot_infos = unreal.AnnEditorBlueprintFunctionLib.get_blueprint_export_info(
        blueprint
    )
    if len(in_content) == 0:
        in_content = get_template_bp_code(name).splitlines(True)
    custom_code = get_custom_bp_code(in_content)
    if not custom_code:
        return False
    new_custom_code = regenerate_custom_bp_code(
        name=name,
        class_name=class_name,
        exprot_infos=exprot_infos,
        custom_code=custom_code,
    )
    end_mark = f"return {name}\n"
    out_content.extend(get_generate_bp_code(name, class_name, exprot_infos))
    out_content.extend(new_custom_code)
    out_content.extend([end_mark])
    return True


def generate_lua_code_bp(blueprint):
    out_content = []
    if not get_bp_code(blueprint=blueprint, out_content=out_content):
        return
    lua_path = FunctionLib.get_asset_script_absolute_path(blueprint)
    FunctionLib.write_file(lua_path, out_content)
    unreal.log(f"{LOG_MARKER}{blueprint.get_name()}")
