if Ann.Core then
	return
end

Ann.Core = {}
Ann.Core.EventManager = require("Core.Both.EventManager")
Ann.Core.SceneManager = require("Core.Both.SceneManager").New()

if Ann.Env.Role == Ann.Define.ERole.Server then
	--TODO
elseif Ann.Env.Role == Ann.Define.ERole.Client then
	Ann.Core.SceneManager = require("Core.Both.UIManager")
	Ann.Core.EventManager = require("Core.Both.HttpManager")
else
	Ann.LogError("Unsupported app role", Ann.Env.Role)
end

Ann.Log("Ann Core module init finished")
