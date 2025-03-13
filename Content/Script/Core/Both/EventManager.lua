---@class EventManager
local EventManager = Ann.Class("EventManager", Ann.Object)

---@overload fun():void 构造
function EventManager:OnInit()
	self.__Role = Ann.Define.ERole.Both
end

---@overload fun():void 析构
function EventManager:OnDestory() end

---@overload fun():void 重置
function EventManager:OnReset() end

return EventManager
