---@class 全局定义
---@field ELogVerbosity table 日志级别
local Define = {}

Define.ELogVerbosity = {
	Log = 3,
	Warn = 2,
	Error = 1,
}

Define.EPlatform = {
	Android = "Android",
	IOS = "IOS",
	Windows = "Windows",
}

Define.ERole = {
	Server = "Server",
	Client = "Client",
	Both = "Both",
}

Ann.Define = Define
