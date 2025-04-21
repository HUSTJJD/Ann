---@class Env 环境变量
---@field LogVerbosity int 当前日志级别
---@field LogTable boolean 日志是否打印table
---@field Platform string  当前的设备平台
---@field Role number 当前客户端角色
---@field bServer boolean 是否服务器
---@field bClient boolean 是否客户端
---@field bEnableTick boolean 是否开启Tick
local Env = {
    EnvValue = {}
}
---注册环境变量
---@public
---@param property string   环境变量名称
---@param value     any     环境变量值
---@param readOnly boolean  是否只读
function Env.Regist(property, value, readOnly)
    local target = Env.EnvValue[property]
    if target and target.readOnly then
        Ann.LogError("Attempt to modify ReadOnly Env", property)
        return
    end
    Env.EnvValue[property] = {
        Value = value,
        ReadOnly = readOnly
    }
end

local function CustomIndex(_, k)
    local property = Env.EnvValue[k]
    if property == nil then
        return nil
    end
    local value = property.Value
    if type(value) == "function" then
        return value()
    else
        return value
    end
end

Env.Regist("LogVerbosity", Ann.Define.ELogVerbosity.Log, true)
Env.Regist("LogTable", true, true)
Env.Regist("Platform", Ann.Define.EPlatform.Windows, true)
Env.Regist("Role", Ann.Define.ERole.Client, true)
Env.Regist("bServer", Env.Role == Ann.Define.ERole.Server, true)
Env.Regist("bClient", not Env.bServer, true)
Env.Regist("bEnableTick", Env.bClient, true)

setmetatable(Env, { __index = CustomIndex })
Ann.Env = Env
