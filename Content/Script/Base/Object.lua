local Object = Ann.Class("Object")

local function IsMistakeRole(ObjectType)
	local bServer = Ann.Env.bServer
	if ObjectType == Ann.Define.ERole.Client and bServer then
		return true
	end
	return false
end

---@private
function Object:Ctor(...)
	self.__TickInterval = 0
	self.__bEnableTick = false
	self.__Role = Ann.Define.ERole.Client
	self:OnInit(...)
	if IsMistakeRole(self.__Role) then
		self:Destory()
		Ann.LogError(self.__cname, self.__Role, "Object Ctor Error, terrible Role")
		return
	end
	if self.__bEnableTick then
		Ann.Tick:AddLoopTicker(self.__TickInterval, self, self.OnTick)
	end
end

---@public
function Object:Destory()
	self:OnDestory()
	if self.__bEnableTick then
		Ann.Tick:ClearObjRef(self)
	end
end

---@public
function Object:Reset()
	self:OnReset()
	if self.__bEnableTick then
		Ann.Tick:ClearObjRef(self)
	end
end

---@public
function Object:OnInit() end

---@public
function Object:OnDestory() end

---@public
function Object:OnReset() end

---@public
---@param deltaSeconds number 时间间隔
-- function Object:OnTick(deltaSeconds) end

Ann.Object = Object
Ann.NewObject = function(modulePath)
	return function(...)
		local module = require(modulePath)
		local _, obj = xpcall(module.New, Ann.LogError, ...)
		return obj
	end
end
