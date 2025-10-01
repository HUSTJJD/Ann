setmetatable(UnLua, {
	__index = function(t, k)
		local ok, result = pcall(require, "UnLua." .. tostring(k))
		if ok then
			rawset(t, k, result)
			return result
		else
			t.LogWarn(string.format("failed to load module UnLua.%s\n%s", k, result))
		end
	end,
})

local HotReloadFunc
if UnLua.HotReloadEnabled then
	local HotReload = require("UnLua.HotReload")
	_G.require = HotReload.require
	HotReloadFunc = function()
		local ret = xpcall(HotReload.reload, UnLua.LogError)
		return ret
	end
else
	HotReloadFunc = function()
		return false
	end
end
UnLua.HotReload = HotReloadFunc

UnLua.Class = require("UnLua.Class")

rapidjson = require("rapidjson")

pb = require("pb")
