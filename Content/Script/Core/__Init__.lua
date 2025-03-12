if Ann.Core then
	return
end

Ann.Core = {}
Ann.Core.EventManager = Ann.NewObject("Core.Both.EventManager")
Ann.Core.SceneManager = Ann.NewObject("Core.Both.SceneManager")

if Ann.Env.Role == Ann.Define.ERole.Server then
	--TODO
elseif Ann.Env.Role == Ann.Define.ERole.Client then
	Ann.Core.SceneManager = Ann.NewObject("Core.Both.UIManager")
	Ann.Core.EventManager = Ann.NewObject("Core.Both.HttpManager")
else
	Ann.LogError("Unsupported app role", Ann.Env.Role)
end

Ann.Log("Ann Core module init finished")
