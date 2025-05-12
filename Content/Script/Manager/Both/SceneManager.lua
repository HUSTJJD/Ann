---@class SceneManager : BaseClass
local SceneManager = Ann.Class("SceneManager", Ann.BaseClass)

---@overload fun():void 构造
function SceneManager:OnInit()
	self.__bSingleton = true
	self.__Role = Ann.Define.ERole.Both
end

---@overload fun():void 析构
function SceneManager:OnClear() end

---@overload fun(deltaSeconds:number):void 时钟
--function SceneManager:OnTick(deltaSeconds)

--end

return SceneManager
