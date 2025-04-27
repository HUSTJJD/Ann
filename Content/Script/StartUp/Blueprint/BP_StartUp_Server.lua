--region GEN_BP

---@class BP_StartUp_Server
local BP_StartUp_Server = UnLua.Class()

--endregion GEN_BP

-- BlueprintEvent
function BP_StartUp_Server:ReceiveBeginPlay()
	Ann.GameInstance:StartUp()
end

-- BlueprintEvent
-- function BP_StartUp_Server:ReceiveEndPlay()

-- end

-- function BP_StartUp_Server:ReceiveTick()

-- end

return BP_StartUp_Server
