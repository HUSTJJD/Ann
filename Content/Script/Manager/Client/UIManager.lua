---@class UIManager : BaseClass
local UIManager = Ann.Class("UIManager", Ann.BaseClass)

---@overload fun():void 构造
function UIManager:OnInit()
	self.__bSingleton = true
end

---@overload fun():void 析构
function UIManager:OnClear() end

---@overload fun(deltaSeconds:number):void 时钟
--function UIManager:OnTick(deltaSeconds)

--end

return UIManager
