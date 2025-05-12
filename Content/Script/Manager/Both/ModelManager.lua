---@class ModelManager : BaseClass
local ModelManager = Ann.Class("ModelManager", Ann.BaseClass)

--- 构造
function ModelManager:OnInit()
	self.__bSingleton = true
	self.__Role = Ann.Define.ERole.Both
end

--- 析构
function ModelManager:OnClear() end

--- 重置
function ModelManager:OnReset() end

return ModelManager
