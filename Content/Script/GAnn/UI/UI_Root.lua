--region GEN_WBP

---@class UI_Root_BP : UUserWidget

---@class UI_Root : BaseView
---@field bp UI_Root_BP
local UI_Root = Ann.Class("UI_Root", Ann.BaseView)
-- 绑定蓝图事件
function UI_Root:BindWidgetDelegate() end

function UI_Root:OnOpen(Data)
	self:Init(Data)
	self:InitView()
	self:BindWidgetDelegate()
	self:BindCustomEvent()
end

--endregion GEN_WBP

-- 初始化数据
function UI_Root:Init(Data)
	self.Data = Data
end

-- 初始化界面
function UI_Root:InitView() end

-- 绑定自定义事件
function UI_Root:BindCustomEvent() end

-- 如需延迟关闭
-- function UI_Root:DelayToClose()
--    return 0
-- end

function UI_Root:OnClose() end

return UI_Root
