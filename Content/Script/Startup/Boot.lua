local BootBoth = Ann.Class("BootBoth")

function BootBoth:Init()
	self.bTick = Ann.Env.bEnableTick
	if self.bTick then
		Ann.Tick:Init()
	end
end

function BootBoth:Shutdown()
	if self.bTick then
		Ann.Tick:Shutdown()
	end
end

function BootBoth:Tick()
	if self.bTick then
		Ann.Tick:Tick()
	end
end

return BootBoth
