---@class BP_StartUp_Client
local BP_StartUp_Client = UnLua.Class()

function BP_StartUp_Client:ReceiveBeginPlay()
    Ann.LogError('BP_StartUp_Client:ReceiveBeginPlay', Ann)
end

function BP_StartUp_Client:ReceiveEndPlay()

end

return BP_StartUp_Client
