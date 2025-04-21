---@class Object 基类
local Object = Ann.Class("Object")

local function CheckObjetRole(ObjectType)
	local bServer = Ann.Env.bServer
	if ObjectType == Ann.Define.ERole.Client and bServer then
		return true
	end
	return false
end

---构造函数
---@private
function Object:Ctor(...)
	self.__TickInterval = 0
	self.__bEnableTick = false
	self.__bSingleton = false
	self.__Role = Ann.Define.ERole.Client
	self:OnInit(...)
	if CheckObjetRole(self.__Role) then
		self:Destory()
		Ann.LogError(self.__cname, self.__Role, "Object Ctor Error, terrible Role")
		return false
	end
	if self.__bEnableTick then
		Ann.Tick:AddLoopTicker(self.__TickInterval, self, self.OnTick)
	end
	return true
end

---析构函数
---@public
function Object:Destory()
	self:OnDestory()
	if self.__bEnableTick then
		Ann.Tick:ClearObjRef(self)
	end
	Ann.DestoryObject(self)
end

---@public
function Object:Reset(...)
	self:OnReset(...)
	if self.__bEnableTick then
		Ann.Tick:ClearObjRef(self)
	end
	if self.__bEnableTick then
		Ann.Tick:AddLoopTicker(self.__TickInterval, self, self.OnTick)
	end
end

---初始化
---@public
function Object.OnInit(...) end

---销毁
---@public
function Object.OnDestory() end

---重置
---@public
function Object.OnReset(...) end

---@public
---@param deltaSeconds number 时间间隔
function Object:OnTick(deltaSeconds) Ann.LogWarn('Unused Tick Function, Please Remove It!', self.__cname, deltaSeconds) end

local Singletons = {}

--- Ann 创建对象
---@param modulePath string module路径
---@return any 对象
local function NewObject(modulePath, ...)
	local instance = Singletons[modulePath]
	if instance ~= nil then
		return instance
	end
	local module = require(modulePath)
	if not module then
		Ann.LogError("Ann NewObject invalid modulePath", modulePath)
		return
	end
	local _, obj = xpcall(module.New, Ann.LogError, ...)
	if obj.__bSingleton then
		Singletons[modulePath] = obj
	end
	return obj
end

--- Ann 销毁对象
---@param obj any module路径
local function DestoryObject(obj)
	if not obj.__bSingleton then
		return
	end
	for k, v in pairs(Singletons) do
		if v == obj then
			Singletons[k] = nil
		end
	end
end

Ann.Object = Object
Ann.NewObject = NewObject
Ann.DestoryObject = DestoryObject
