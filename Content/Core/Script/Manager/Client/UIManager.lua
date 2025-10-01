---@class UIManager : BaseClass
local UIManager = Ann.Class("UIManager", Ann.BaseClass)

---@overload fun():void 构造
function UIManager:OnInit()
	self.__bSingleton = true
end

---@overload fun():void 析构
function UIManager:OnClear() end

--[[
---@overload fun(deltaSeconds:number):void 时钟
function UIManager:OnTick(deltaSeconds)
end
]]

---@private fun():AnnClass
function UIManager:GetUIRoot()
	if self.m_root == nil then
		local UI_Root_BP = UE.LoadObject()
		local UI_Root_Obj = UE.UWidgetBlueprintLibrary.Create(Ann.GameInstance, UI_Root_BP)
		local UI_Root = Ann.NewObject(UI_Root_Obj, "UI_Root")
		UI_Root:Open()
		UI_Root.bp:AddToViewport()
		self.m_root = UI_Root
	end
	return self.m_root
end

return UIManager
