---@class Define 全局定义
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
	Standalone = "Standalone",
	DedicatedServer = "DedicatedServer",
	ListenServer = "ListenServer",
	Client = "Client",
}

Ann.Define = Define
