--region GEN_BP

---@class BP_StartUp_Client
local BP_StartUp_Client = UnLua.Class()

--endregion GEN_BP

-- BlueprintEvent
function BP_StartUp_Client:ReceiveBeginPlay()
	Ann.GameInstance:StartUp()
end

-- BlueprintEvent
-- function BP_StartUp_Client:ReceiveEndPlay()

-- end

-- function BP_StartUp_Client:ReceiveTick()

-- end

return BP_StartUp_Client
