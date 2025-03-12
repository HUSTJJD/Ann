local function Print(func, verbosity, ...)
	if Ann.Env.LogVerbosity < verbosity then
		return
	end
	if Ann.Env.LogTable then
		local args = { ... }
		local out = {}
		for _, v in ipairs(args) do
			if type(v) == "table" then
				table.insert(out, rapidjson.encode(v))
			else
				table.insert(out, tostring(v))
			end
		end
		func(table.concat(out, " "))
	else
		func(...)
	end
end

local function Log(...)
	Print(UnLua.Log, Ann.Define.ELogVerbosity.Log, ...)
end

local function LogWarn(...)
	Print(UnLua.LogWarn, Ann.Define.ELogVerbosity.Warn, ...)
end

local function LogError(...)
	Print(UnLua.LogError, Ann.Define.ELogVerbosity.Error, ...)
end

Ann.Log = Log
Ann.LogWarn = LogWarn
Ann.LogError = LogError
