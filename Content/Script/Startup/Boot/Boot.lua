local Boot = Ann.Class("Boot")

function Boot:Init()
	Ann.Tick = require("Base.Tick").New()
	Ann.Tick:Init()
end

function Boot:Shutdown()
	Ann.Tick:Shutdown()
end

function Boot:Tick()
	Ann.Tick:Tick()
end

return Boot
