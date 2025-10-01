---@class BP_AnnGameInstance : UAnnGameInstance Lua 入口
local BP_AnnGameInstance = UnLua.Class()
---Ann 启动
---@private
function BP_AnnGameInstance:ReceiveInit()
	Ann = {}
	Ann.GameInstance = self
	require("Core.Script.__Init__")
end

---Ann 关闭
---@private
function BP_AnnGameInstance:ReceiveShutdown()
	if self.boot then
		self.boot:Shutdown()
	end
end

---Ann 关闭
---@private
function BP_AnnGameInstance:ReceiveTick()
	if self.boot then
		self.boot:Tick()
	end
end

---Ann 启动
---@public
function BP_AnnGameInstance:StartUp()
	self.boot = Ann.NewObject("Startup.Script.Boot")
	if self.boot then
		self.boot:Init()
	end
end

return BP_AnnGameInstance
