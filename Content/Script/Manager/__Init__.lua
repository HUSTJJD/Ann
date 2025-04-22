if Ann.Env.Role == Ann.Define.ERole.Server then
    --TODO
elseif Ann.Env.Role == Ann.Define.ERole.Client then
    Ann.UIManager = Ann.NewObject("Core.Client.UIManager")
    Ann.HttpManager = Ann.NewObject("Core.Client.HttpManager")
else
    Ann.LogError("Unsupported app role", Ann.Env.Role)
end
Ann.EventManager = Ann.NewObject("Core.Both.EventManager")
Ann.SceneManager = Ann.NewObject("Core.Both.SceneManager")

Ann.Log("Ann Core module init finished")
