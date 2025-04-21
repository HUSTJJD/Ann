---@class Boot
local Boot = Ann.Class("Boot")

function Boot:Init()
	self.bTick = Ann.Env.bEnableTick
	if self.bTick then
		Ann.Tick:Init()
	end
end

function Boot:Shutdown()
	if self.bTick then
		Ann.Tick:Shutdown()
	end
end

function Boot:Tick()
	if self.bTick then
		Ann.Tick:Tick()
	end
end

return Boot
