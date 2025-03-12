---@class Ann全局表
_G.Ann = _G.Ann or {}
require("Base.Class")
require("Base.Define")
require("Base.Logger")
require("Base.Object")
require("Base.Env")

local BootPath = string.format("Startup.Boot.Boot%s", Ann.Env.Role)

local Boot = require(BootPath).New()

return Boot
