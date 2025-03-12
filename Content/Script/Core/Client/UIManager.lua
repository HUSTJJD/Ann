---@class UIManager
local UIManager = Ann.Class("UIManager", Ann.Object)

---@overload fun():void 构造
function UIManager:OnInit()
	--self.__TickInterval = 0
	--self.__bEnableTick = false
	--self.__Role = Ann.Define.ERole.Client
end

---@overload fun():void 析构
function UIManager:OnDestory() end

---@overload fun(deltaSeconds:number):void 时钟
--function UIManager:OnTick(deltaSeconds)

--end

return UIManager
