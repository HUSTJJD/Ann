---@class BaseView : BaseClass
local BaseView = Ann.Class("BaseView", Ann.BaseClass)

--- 构造
function BaseView:OnInit(widget, widgetName, beCreate)
	self.bp = widget
	self.m_beCache = widget and widget.beCache
	self.m_widgetName = widgetName
	self.m_bNewCreate = beCreate
end

--- 析构
function BaseView:OnDestory()
	self.bp = nil
end

--- 重置
function BaseView:OnReset() end

--region Interface

function BaseView:OnOpen() end

function BaseView:DelayToClose()
	return 0
end

function BaseView:OnClose() end

function BaseView:OnShow() end

function BaseView:OnHide() end

--endregion

--region BindEvent

function BaseView:BindDelegate(widget, delegate, func)
	if widget and delegate and func and widget[delegate] then
		local function func_warp(...)
			func(self, ...)
		end
		widget[delegate]:Add(self.bp, func_warp)
	end
end

--endregion

Ann.BaseView = BaseView
