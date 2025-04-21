if Ann.Core then
	return
end

Ann.Core = {}

-- local function RegistModule(role)
-- 	local BasePath = string.format("Core.%s", role)

-- end
Ann.Core.EventManager = Ann.NewObject("Core.Both.EventManager")
Ann.Core.SceneManager = Ann.NewObject("Core.Both.SceneManager")

-- local role = Ann.Env.Role

if Ann.Env.Role == Ann.Define.ERole.Server then
	--TODO
elseif Ann.Env.Role == Ann.Define.ERole.Client then
	Ann.Core.UIManager = Ann.NewObject("Core.Client.UIManager")
	Ann.Core.HttpManager = Ann.NewObject("Core.Client.HttpManager")
else
	Ann.LogError("Unsupported app role", Ann.Env.Role)
end

Ann.Log("Ann Core module init finished")
