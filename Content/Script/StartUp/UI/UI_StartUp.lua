--region GEN_WBP

---@class UI_StartUp_BP : UUserWidget

---@class UI_StartUp : BaseView
---@field bp UI_StartUp_BP
local UI_StartUp = Ann.Class("UI_StartUp", Ann.BaseView)
-- 绑定蓝图事件
function UI_StartUp:BindWidgetDelegate() end

function UI_StartUp:OnOpen(Data)
	self:Init(Data)
	self:InitView()
	self:BindWidgetDelegate()
	self:BindCustomEvent()
end

--endregion GEN_WBP

-- 初始化数据
function UI_StartUp:Init(Data)
	self.Data = Data
end

-- 初始化界面
function UI_StartUp:InitView() end

-- 绑定自定义事件
function UI_StartUp:BindCustomEvent() end

-- 如需延迟关闭
-- function UI_Root:DelayToClose()
--    return 0
-- end

function UI_StartUp:OnClose() end

return UI_StartUp
