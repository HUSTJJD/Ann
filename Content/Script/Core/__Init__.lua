---@class Ann 全局表
---@field Class fun(clsName: string, ...):table
---@field IsA fun(A: table, B: table):boolean
---@field Define Define
---@field Env Env
---@field Log fun(...):nil
---@field LogWarn fun(...):nil
---@field LogError fun(...):nil
---@field BaseClass BaseClass
---@field NewObject fun(modulePath: string, ...):BaseClass|nil
---@field Tick Tick
_G.Ann = _G.Ann or {}
require("Core.Class")
require("Core.Define")
require("Core.Logger")
require("Core.Env")
require("Core.Tick")
require("Core.Base.BaseEnum")
require("Core.Base.BaseClass")
require("Core.Base.BaseView")

Ann.Log("Ann Base module init finished")
