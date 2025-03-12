---@class SceneManager
local SceneManager = Ann.Class("SceneManager", Ann.Object)

---@overload fun():void 构造
function SceneManager:OnInit()
	--self.__TickInterval = 0
	--self.__bEnableTick = false
	self.__Role = Ann.Define.ERole.Both
end

---@overload fun():void 析构
function SceneManager:OnDestory() end

---@overload fun(deltaSeconds:number):void 时钟
--function SceneManager:OnTick(deltaSeconds)

--end

return SceneManager
