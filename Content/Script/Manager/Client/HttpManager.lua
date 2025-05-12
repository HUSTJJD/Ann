---@class HttpManager : BaseClass
local HttpManager = Ann.Class("HttpManager", Ann.BaseClass)

---@overload fun():void 构造
function HttpManager:OnInit()
	self.__bSingleton = true
end

---@overload fun():void 析构
function HttpManager:OnClear() end

---@overload fun():void 重置
function HttpManager:OnReset() end

---@overload fun(deltaSeconds:number):void 时钟
--function HttpManager:OnTick(deltaSeconds)

--end

return HttpManager
