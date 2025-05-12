---@class Env 环境变量
---@field LogVerbosity int 当前日志级别
---@field LogTable boolean 日志是否打印table
---@field Platform string  当前的设备平台
---@field Role number 当前客户端角色
---@field bServer boolean 是否服务器
---@field bClient boolean 是否客户端
---@field bEnableTick boolean 是否开启Tick
---@field bShipping boolean BuildConfiguration
---@field bTest boolean BuildConfiguration
---@field bDevelopment boolean BuildConfiguration
---@field bDebug boolean BuildConfiguration
---@field bDebugGame boolean BuildConfiguration
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
        return
    end
    local value = property.Value
    if type(value) == "function" then
        return value()
    else
        return value
    end
end

setmetatable(Env, { __index = CustomIndex })

Ann.Env = Env

local Platform = UE.UGameplayStatics.GetPlatformName()
Env.Regist("Platform", Platform, true)

local Role = Ann.Define.ERole.ListenServer
if not UE.UKismetSystemLibrary.IsServer(Ann.GameInstance) then
    Role = Ann.Define.ERole.Client
elseif UE.UKismetSystemLibrary.IsDedicatedServer(Ann.GameInstance) then
    Role = Ann.Define.ERole.DedicatedServer
elseif UE.UKismetSystemLibrary.IsStandalone(Ann.GameInstance) then
    Role = Ann.Define.ERole.Standalone
end
Env.Regist("Role", Role, true)
Env.Regist("bDedicatedServer", Env.Role == Ann.Define.ERole.DedicatedServer, true)
Env.Regist("bClient", Env.Role == Ann.Define.ERole.Client or Env.Role == Ann.Define.ERole.ListenServer, true)
Env.Regist("bServer", not Env.bClient or Env.Role == Ann.Define.ERole.ListenServer, true)
Env.Regist("bEnableTick", Env.bClient, true)

local BuildConfiguration = UE.UKismetSystemLibrary.GetBuildConfiguration()
Env.Regist("bShipping", BuildConfiguration == "Shipping", true)
Env.Regist("bTest", BuildConfiguration == "Test", true)
Env.Regist("bDevelopment", BuildConfiguration == "Development", true)
Env.Regist("bDebug", BuildConfiguration == "Debug", true)
Env.Regist("bDebugGame", BuildConfiguration == "DebugGame", true)

local LogVerbosity = Env.bShipping and Ann.Define.ELogVerbosity.Error or Ann.Define.ELogVerbosity.Log
Env.Regist("LogVerbosity", LogVerbosity, true)
Env.Regist("LogTable", not Env.bShipping, true)
