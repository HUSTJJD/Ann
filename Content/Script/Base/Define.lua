---@class Define 全局定义
---@field ELogVerbosity table 日志级别
---@field EPlatform table 平台
---@field ERole table App角色
local Define = {}

Define.ELogVerbosity = {
	Log = 3,
	Warn = 2,
	Error = 1,
}

Define.EPlatform = {
	Android = "Android",
	IOS = "IOS",
	OpenHarmony = "OpenHarmony",
	Windows = "Windows",
	Linux = "Linux",
	MacOS = "MacOS",
}

Define.ERole = {
	Server = "Server",
	Client = "Client",
	Both = "Both",
}

Ann.Define = Define
