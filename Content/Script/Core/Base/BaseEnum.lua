---@class BaseEnum
local BaseEnum = {
	__index = function(t, key)
		local raw_v
		if t.__EnumType == "number" then
			raw_v = tonumber(key)
		end
		raw_v = raw_v or key
		return raw_v
	end,
}

Ann.BaseEnum = BaseEnum
