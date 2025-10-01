---@class EventManager : BaseClass
local EventManager = Ann.Class("EventManager", Ann.BaseClass)

--- 构造
function EventManager:OnInit()
	self.__bSingleton = true
	self.__Role = Ann.Define.ERole.Both
end

--- 析构
function EventManager:OnClear() end

--- 重置
function EventManager:OnReset() end

return EventManager
