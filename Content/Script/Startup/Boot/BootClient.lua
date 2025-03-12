local Boot = require("Startup.Boot.Boot")
local BootClient = Ann.Class("BootClient", Boot)

function BootClient:Init()
	self.CallSuper(self, "Init")
end

function BootClient:Shutdown()
	self.CallSuper(self, "Shutdown")
end

function BootClient:Tick()
	self.CallSuper(self, "Tick")
end

return BootClient
