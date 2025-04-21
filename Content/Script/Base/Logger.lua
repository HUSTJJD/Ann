local function PrintTable(out, in_v, d)
	if d > 8 then
		return
	end
    local out_v = {}
    for k, v in pairs(in_v) do
        local v_t = type(v)
        if v_t == 'table' then
            local t = {}
            PrintTable(t, v, d + 1)
            out_v[k] = t
        elseif v_t == 'string' or v_t == 'number' or v_t == 'boolean' then
            out_v[k] = v
		else
			out_v[k] = tostring(v)
        end
    end
    table.insert(out, out_v)
end

local function Print(func, verbosity, ...)
    if Ann.Env.LogVerbosity < verbosity then
        return
    end
    if Ann.Env.LogTable then
        local args = { ... }
        local out = {}
		PrintTable(out, args, 1)
        func(rapidjson.encode(out))
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
    local trace = debug.traceback(nil, 2)
    Print(UnLua.LogError, Ann.Define.ELogVerbosity.Error, trace)
end

Ann.Log = Log
Ann.LogWarn = LogWarn
Ann.LogError = LogError
