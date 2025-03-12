local Boot = require("Startup.Boot.BootBoth")
local BootServer = Ann.Class("BootServer", Boot)
function BootServer:Init()
	self.CallSuper(self, "Init")
end

function BootServer:Shutdown()
	self.CallSuper(self, "Shutdown")
end

function BootServer:Tick()
	self.CallSuper(self, "Tick")
end

return BootServer
