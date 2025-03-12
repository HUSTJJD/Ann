---@class EventManager
local EventManager = Ann.Class("EventManager", Ann.Object)

---@overload fun():void 构造
function EventManager:OnInit()
	--self.__TickInterval = 0
	--self.__bEnableTick = false
	self.__Role = Ann.Define.ERole.Both
end

---@overload fun():void 析构
function EventManager:OnDestory() end

---@overload fun(deltaSeconds:number):void 时钟
--function EventManager:OnTick(deltaSeconds)

--end

return EventManager
