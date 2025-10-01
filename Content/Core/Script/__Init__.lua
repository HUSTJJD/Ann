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
require("Core.Script.Class")
require("Core.Script.Define")
require("Core.Script.Logger")
require("Core.Script.Script.Env")
require("Core.Script.Tick")
require("Core.Script.Base.BaseEnum")
require("Core.Script.Base.BaseClass")
require("Core.Script.Base.BaseView")

Ann.Log("Ann Base module init finished")
