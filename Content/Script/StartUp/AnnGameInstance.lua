---@class AnnGameInstance : UGameInstance Lua 入口
local AnnGameInstance = UnLua.Class()

---Ann 启动
---@private
function AnnGameInstance:ReceiveInit()
	Ann = {}
	Ann.GameInstance = self
	require("ThirdParty.__Init__")
	require("Core.__Init__")
end

---Ann 关闭
---@private
function AnnGameInstance:ReceiveShutdown()
	if self.boot then
		self.boot:Shutdown()
	end
end

---Ann 关闭
---@private
function AnnGameInstance:ReceiveTick()
	if self.boot then
		self.boot:Tick()
	end
end

---Ann 启动
---@public
function AnnGameInstance:StartUp()
	self.boot = Ann.NewObject("Startup.Boot")
	if self.boot then
		self.boot:Init()
	end
end

return AnnGameInstance
