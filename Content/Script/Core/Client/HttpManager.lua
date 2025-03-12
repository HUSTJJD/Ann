---@class HttpManager
local HttpManager = Ann.Class("HttpManager", Ann.Object)

---@overload fun():void 构造
function HttpManager:OnInit()
	--self.__TickInterval = 0
	--self.__bEnableTick = false
	--self.__Role = Ann.Define.ERole.Client
end

---@overload fun():void 析构
function HttpManager:OnDestory() end

---@overload fun():void 重置
function HttpManager:OnReset() end

---@overload fun(deltaSeconds:number):void 时钟
--function HttpManager:OnTick(deltaSeconds)

--end

return HttpManager
