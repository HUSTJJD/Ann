---@class Ann全局表
require("Base.__Init__")

local BootPath = string.format("Startup.Boot.Boot%s", Ann.Env.Role)

local Boot = require(BootPath).New()

return Boot
