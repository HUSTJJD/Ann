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
	self:OnCtor(...)
	if IsMistakeRole(self.__Role) then
		self:Destory()
		return
	end
	if self.__bEnableTick and Ann.Env.bEnableTick then
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
function Object:OnCtor() end

---@public
function Object:OnDestory() end

---@public
-- function Object:OnTick()
-- end

Ann.Object = Object
