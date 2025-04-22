local recursionsetmetatable
recursionsetmetatable = function(t, index)
	local mt = getmetatable(t)
	if not mt then
		mt = {}
	end
	if not mt.__index then
		mt.__index = index
		mt.__gc = function(self)
			self:Dtor()
		end
		setmetatable(t, mt)
	elseif mt.__index ~= index then
		recursionsetmetatable(mt, index)
	end
end

---Ann Lua 类定义
---@public
---@param clsName string 类名
---@vararg table|func 基类
local function Class(clsName, ...)
	local cls = { __cname = clsName }
	local supers = { ... }
	-- super 可以是table 可以是function
	for _, super in ipairs(supers) do
		local superType = type(super)
		if superType == "function" then
			cls.__create = super
		elseif superType == "table" then
			cls.__supers = cls.__supers or {}
			cls.__supers[#cls.__supers + 1] = super
		end
	end
	cls.__index = cls
	local mt = {
		__call = function(_cls, ...)
			return _cls.New(...)
		end,
		-- __gc = function(cls) end
	}
	if cls.__supers then
		mt.__index = function(_, key)
			for _, super in ipairs(cls.__supers) do
				if super[key] then
					return super[key]
				end
			end
		end
	end
	setmetatable(cls, mt)
	-- 必然是成员函数
	cls.CallSuper = function(self, funcName, ...)
		if cls.__supers then
			for _, super in ipairs(cls.__supers) do
				local superFunc = super[funcName]
				if type(superFunc) == "function" then
					superFunc(self, ...)
				end
			end
		end
	end
	if not cls.Ctor then
		cls.Ctor = function()
			return true
		end
	end
	cls.New = function(...)
		local self = cls.__create and cls.__create(...) or {}
		recursionsetmetatable(self, cls)
		self:Ctor(...)
		return self
	end
	return cls
end

---Ann Lua 类型判断 A 是不是 B
---@public
---@param A table Class or Object A
---@param B table Class or Object B
---@return boolean
local function IsA(A, B)
	local recursionIsA
	recursionIsA = function(clsA, clsB)
		if clsA.__supeclsArs then
			for _, super in ipairs(clsA.__supers) do
				if recursionIsA(super, clsB) or super.__cname == clsB.__cname then
					return true
				end
			end
		end
	end
	return recursionIsA(A, B) or A.__cname == B.__cname
end

Ann.Class = Class
Ann.IsA = IsA
