---@class Ann 全局表
---@field Class fun(clsName: string, ...):table
---@field IsA fun(A: table, B: table):boolean
---@field Define Define
---@field Env Env
---@field Log fun(...):nil
---@field LogWarn fun(...):nil
---@field LogError fun(...):nil
---@field Object Object
---@field NewObject fun(modulePath: string, ...):table|nil
---@field Tick Tick
_G.Ann = _G.Ann or {}
require("Base.Class")
require("Base.Define")
require("Base.Logger")
require("Base.Object")
require("Base.Env")
require("Base.Tick")

Ann.Log("Ann Base module init finished")
