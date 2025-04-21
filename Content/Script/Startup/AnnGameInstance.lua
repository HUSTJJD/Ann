---@class AnnGameInstance Lua 入口
local AnnGameInstance = UnLua.Class()

---Ann 启动
---@private
function AnnGameInstance:ReceiveInit()
	require("Base.__Init__")
	require("Core.__Init__")
	require("ThirdParty.__Init__")

	Ann.GameInstance = self
	self.boot = Ann.NewObject("Startup.Boot")
	self.boot:Init()
end

---Ann 关闭
---@private
function AnnGameInstance:ReceiveShutdown()
	self.boot:Shutdown()
end

---Ann 关闭
---@private
function AnnGameInstance:ReceiveTick()
	self.boot:Tick()
end

return AnnGameInstance
