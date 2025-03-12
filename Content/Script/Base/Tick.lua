local Tick = Ann.Class("Tick")

local function Container(interval, obj, func, delay, ...)
	local container = {
		Obj = obj,
		Func = func,
		Last = 0,
		Interval = interval,
		Delay = delay,
		Param = { ... },
	}
	function container:Call(...)
		if self.Func and self.Obj then
			xpcall(self.Func(self.Obj, ...), Ann.LogError)
		end
	end

	function container:Pause()
		self.bPause = true
	end

	function container:Resume()
		self.bPause = false
	end

	function container:Stop()
		self.bStop = true
	end

	return container
end

function Tick:Init(...)
	self.TickerList = {}
	self.TimerList = {}
	self.__TickCount = 0
	self.__LastTime = 0
end

function Tick:Shutdown(...)
	self.TickerList = {}
	self.TimerList = {}
	self.__TickCount = 0
	self.__LastTime = 0
end

function Tick:AddLoopTicker(interval, obj, func)
	local ticker = Container(math.ceil(interval), obj, func)
	table.insert(self.TickerList, ticker)
	return ticker
end

function Tick:RemoveTicker(ticker)
	for i = #self.TickerList, 1, -1 do
		local _ticker = self.TickerList[i]
		if _ticker == ticker then
			table.remove(self.TickerList, i)
		end
	end
end

function Tick:AddLoopTimer(interval, obj, func)
	local ticker = Container(interval, obj, func)
	table.insert(self.TickerList, ticker)
	return ticker
end

function Tick:RemoveTimer(timer)
	for i = #self.TimerList, 1, -1 do
		local _timer = self.TimerList[i]
		if _timer == timer then
			table.remove(self.TimerList, i)
		end
	end
end

function Tick:ClearObjRef(obj)
	for i = #self.TickerList, 1, -1 do
		local _ticker = self.TickerList[i]
		if _ticker.Obj == obj then
			table.remove(self.TickerList, i)
		end
	end
	for i = #self.TimerList, 1, -1 do
		local _timer = self.TimerList[i]
		if _timer.Obj == obj then
			table.remove(self.TimerList, i)
		end
	end
end

function Tick:Tick(deltaSeconds)
	local tickCount = (self.__TickCount + 1) % math.maxinteger
	for i = #self.TickerList, 1, -1 do
		local ticker = self.TickerList[i]
		local interval = tickCount - ticker.Last
		if interval == ticker.Interval then
			ticker.Func(ticker.Obj, deltaSeconds)
			ticker.Last = self.__TickCount
		end
	end
	local curTime = os.time()
	for i = #self.TimerList, 1, -1 do
		local timer = self.TimerList[i]
		local interval = curTime - timer.Last
		if interval >= timer.Interval then
			timer:Call(interval)
			timer.Last = curTime
		end
	end
	self.__TickCount = tickCount
	self.__LastTime = curTime
end

Ann.Tick = Tick.New()
