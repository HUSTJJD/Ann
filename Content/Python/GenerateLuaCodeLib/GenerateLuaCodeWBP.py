import unreal
import FunctionLib

AUTO_GENERATE_MARK_BEGIN = "--region GEN_WBP\n"
AUTO_GENERATE_MARK_END = "--endregion GEN_WBP\n"

LOG_MARKER = "generate_lua_code_wbp: "

standard_names = {
    "BackgroundBlur": "bgBlur_",
    "BackgroundBlurSlot": "bgBlurSlot_",
    "Border": "border_",
    "BorderSlot": "borderSlot_",
    "Button": "btn_",
    "ButtonSlot": "btnSlot_",
    "CanvasPanel": "canvas_",
    "CanvasPanelSlot": "canvasSlot_",
    "CheckBox": "check_",
    "CircularThrobber": "throbber_",
    "ComboBox": "combo_",
    "ComboBoxKey": "comboKey_",
    "ComboBoxString": "comboStr_",
    "ContentWidget": "content_",
    "DynamicEntryBox": "dynamicEntry_",
    "DynamicEntryBoxBase": "dynamicBase_",
    "EditableText": "editText_",
    "EditableTextBox": "editBox_",
    "ExpandableArea": "expArea_",
    "GridPanel": "grid_",
    "GridSlot": "gridSlot_",
    "HorizontalBox": "hBox_",
    "HorizontalBoxSlot": "hBoxSlot_",
    "Image": "img_",
    "InputKeySelector": "keySelect_",
    "InvalidationBox": "invalid_",
    "ListView": "list_",
    "ListViewBase": "listBase_",
    "MenuAnchor": "menu_",
    "MultiLineEditableText": "multiText_",
    "MultiLineEditableTextBox": "multiBox_",
    "NamedSlot": "nSlot_",
    "NamedSlotInterface": "nSlotItf_",
    "NativeWidgetHost": "nativeWidget_",
    "Overlay": "overlay_",
    "OverlaySlot": "overlaySlot_",
    "PanelSlot": "panelSlot_",
    "PanelWidget": "panel_",
    "PostBufferBlurUpdater": "blurUpdater_",
    "PostBufferUpdate": "bufUpdate_",
    "ProgressBar": "progress_",
    "RetainerBox": "retainer_",
    "RichTextBlock": "richText_",
    "RichTextBlockDecorator": "textDecor_",
    "RichTextBlockImageDecorator": "imgDecor_",
    "SafeZone": "safe_",
    "SafeZoneSlot": "safeSlot_",
    "ScaleBox": "scale_",
    "ScaleBoxSlot": "scaleSlot_",
    "ScrollBar": "scroll_",
    "ScrollBox": "scrollBox_",
    "ScrollBoxSlot": "scrollSlot_",
    "SizeBox": "size_",
    "SizeBoxSlot": "sizeSlot_",
    "Slider": "slider_",
    "Spacer": "space_",
    "SpinBox": "spin_",
    "StackBox": "stack_",
    "StackBoxSlot": "stackSlot_",
    "TextBlock": "text_",
    "TextWidgetTypes": "textTypes_",
    "Throbber": "throb_",
    "TileView": "tile_",
    "TreeView": "tree_",
    "UniformGridPanel": "uniGrid_",
    "UniformGridSlot": "uniGridSlot_",
    "VerticalBox": "vBox_",
    "VerticalBoxSlot": "vBoxSlot_",
    "Viewport": "view_",
    "Visual": "visual_",
    "Widget": "widget_",
    "WidgetComponent": "widgetComp_",
    "WidgetInteractionComponent": "widgetInter_",
    "WidgetSwitcher": "switcher_",
    "WidgetSwitcherSlot": "switcherSlot_",
    "WindowTitleBarArea": "titleBar_",
    "WindowTitleBarAreaSlot": "titleBarSlot_",
    "WrapBox": "wrap_",
    "WrapBoxSlot": "wrapSlot_",
}

standard_bind_event = {
    "UButton": "Click",
    "UEditableTextBox": "CommittedEditText",
    "USlider": "SliderValueChanged",
    "UCheckBox": "CheckBoxStateChanged",
    "UComboBoxString": "ComboBoxSelectionChanged",
}

standard_rpc = [
    "NetServer",
    "NetClient",
    "NetMulticast",
]


def show_message(widget_blueprint, message, is_error):
    name = widget_blueprint.get_name()
    unreal.EditorDialog.show_message(
        title="generate_lua_code_wbp",
        message=f"{name}\n{message}",
        message_type=unreal.AppMsgType.OK,
        message_category=is_error
        and unreal.AppMsgCategory.ERROR
        or unreal.AppMsgCategory.SUCCESS,
    )
    if is_error:
        unreal.log_error(f"generate_lua_code_wbp\n{name}\n{message}")
    else:
        unreal.log(f"generate_lua_code_wbp\n{name}\n{message}")


def check_widget_variable_name(widget_blueprint: unreal.WidgetBlueprint):
    type_names, var_names = (
        unreal.AnnEditorBlueprintFunctionLib.get_widget_tree_type_name(
            widget_blueprint=widget_blueprint
        )
    )
    error_message = "please rename as recommend\n"
    check_pass = True
    for i in range(len(type_names)):
        type_name = type_names[i]
        var_name = var_names[i]
        standard_name = standard_names.get(type_name, type_name)
        if not var_name.startswith(standard_name):
            error_message += f"{type_name} : {var_name} ({standard_name})\n"
            check_pass = False
    if not check_pass:
        show_message(
            widget_blueprint=widget_blueprint, message=error_message, is_error=True
        )
    return check_pass


def get_bind_native_event_function_name(prop_name, prop_type):
    if prop_type in standard_bind_event:
        parts = prop_name.replace(standard_names[prop_type[1:]], "").split("_")
        func_name = "".join(part.capitalize() for part in parts)
        return func_name


def get_bind_native_event_view_code(prop_name, prop_type):
    if prop_type in standard_bind_event:
        func_name = get_bind_native_event_function_name(prop_name, prop_type)
        event_name = standard_bind_event.get(prop_type)
        return f"\tself:BindDelegate(self.bp.{prop_name}, self.On{event_name}{func_name})\n"


def get_generate_view_code(name, class_name, exprot_infos):
    props = []
    widget_props = []
    bind_native_events = []
    functions = []
    for exprot_info in exprot_infos:
        if exprot_info.owner_class != class_name:
            continue
        field = f"---@field {exprot_info.name} {exprot_info.type} {exprot_info.flag}\n"
        if exprot_info.type != "UFunction":
            if exprot_info.type[1:] in standard_names:
                widget_props.append(field)
            else:
                props.append(field)
            event = get_bind_native_event_view_code(
                prop_name=exprot_info.name, prop_type=exprot_info.type
            )
            bind_native_events.append(event) if event else None
        else:
            functions.append(field)
    widget_props.sort()
    functions.sort()
    props.sort()
    bind_native_events.sort()
    widget_props.extend(props)
    widget_props.extend(functions)
    generate = f"""\
{AUTO_GENERATE_MARK_BEGIN}
---@class {name}_BP : UUserWidget
{''.join(widget_props)}
---@class {name} : BaseView
---@field bp {name}_BP
local {name} = Ann.Class("{name}", Ann.BaseView)
-- 绑定蓝图事件
function {name}:BindWidgetDelegate(){''.join(bind_native_events) if len(bind_native_events) > 0 else ' '}end\n
function {name}:OnOpen(Data)
\tself:Init(Data)
\tself:InitView()
\tself:BindWidgetDelegate()
\tself:BindCustomEvent()
end\n
{AUTO_GENERATE_MARK_END}"""
    return generate


def get_template_view_code(name):
    template = f"""\
{AUTO_GENERATE_MARK_BEGIN}
{AUTO_GENERATE_MARK_END}
-- 初始化数据
function {name}:Init(Data)
\tself.Data = Data
end\n
-- 初始化界面
function {name}:InitView()\n
end\n
-- 绑定自定义事件
function {name}:BindCustomEvent()\n
end\n
-- 如需延迟关闭
-- function UI_Root:DelayToClose()
--    return 0
-- end\n
function {name}:OnClose()\n
\tself.Data = nil
end\n
return {name}
"""
    return template


def get_custom_view_code(in_content):
    auto_gen_end = in_content.index(AUTO_GENERATE_MARK_END)
    if not auto_gen_end:
        unreal.log_error(LOG_MARKER + f"not found {AUTO_GENERATE_MARK_END}")
        return
    return in_content[auto_gen_end + 1 :]


def regenerate_custom_view_code(name, class_name, exprot_infos, custom_code):
    end_mark = f"return {name}\n"
    custom_code_end = custom_code.index(end_mark)
    if not custom_code_end:
        unreal.log_error(LOG_MARKER + f"not found {end_mark}")
        return
    new_custom_code = custom_code[:custom_code_end]
    lua_functions = []
    native_events = []
    for exprot_info in exprot_infos:
        if exprot_info.owner_class != class_name:
            continue
        if exprot_info.type == "UFunction":
            if exprot_info.type in standard_rpc:
                lua_functions.append((f"{exprot_info.name}_RPC", exprot_info.flag))
            else:
                lua_functions.append((f"{exprot_info.name}", exprot_info.flag))
        elif exprot_info.type in standard_bind_event:
            func_name = get_bind_native_event_function_name(
                exprot_info.name, exprot_info.type
            )
            native_events.append(
                (f"On{standard_bind_event.get(exprot_info.type)}{func_name}", None)
            )
    lua_functions.sort()
    native_events.sort()
    lua_functions.extend(native_events)
    for function_name, annotation in lua_functions:
        if not FunctionLib.is_exist_lua_function(
            custom_code, asset_name=name, function_name=function_name
        ):
            if annotation:
                new_custom_code.append(f"-- {annotation}\n")
            new_custom_code.append(f"function {name}:{function_name}()\n\nend\n\n")
    return new_custom_code


def get_view_code(widget_blueprint, out_content: list):
    name = widget_blueprint.get_name()
    lua_path = FunctionLib.get_asset_script_absolute_path(widget_blueprint)
    in_content = FunctionLib.read_file(lua_path)
    class_name = widget_blueprint.generated_class().get_name()
    exprot_infos = unreal.AnnEditorBlueprintFunctionLib.get_blueprint_export_info(
        widget_blueprint
    )
    if len(in_content) == 0:
        in_content = get_template_view_code(name).splitlines(True)
    custom_code = get_custom_view_code(in_content)
    if not custom_code:
        return False
    new_custom_code = regenerate_custom_view_code(
        name=name,
        class_name=class_name,
        exprot_infos=exprot_infos,
        custom_code=custom_code,
    )
    end_mark = f"return {name}\n"
    out_content.extend(get_generate_view_code(name, class_name, exprot_infos))
    out_content.extend(new_custom_code)
    out_content.extend([end_mark])
    return True


def generate_lua_code_wbp(widget_blueprint):
    if not check_widget_variable_name(widget_blueprint):
        return
    out_content = []
    if not get_view_code(widget_blueprint=widget_blueprint, out_content=out_content):
        return
    # require_path = FunctionLib.get_asset_script_require_path(widget_blueprint)
    lua_path = FunctionLib.get_asset_script_absolute_path(widget_blueprint)
    FunctionLib.write_file(lua_path, out_content)
    # widget_blueprint.set_editor_property('ViewScript', require_path)
    unreal.log(f"{LOG_MARKER}{widget_blueprint.get_name()}")
