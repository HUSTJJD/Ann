---@class Boot
local Boot = Ann.Class("Boot")

local function ParseCommandLine()
	local commandLine = UE.UKismetSystemLibrary.GetCommandLine()
	local tokens, switches, params = UE.UKismetSystemLibrary.ParseCommandLine(commandLine)
	return tokens, switches, params
end

function Boot:Init()
	ParseCommandLine()
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
