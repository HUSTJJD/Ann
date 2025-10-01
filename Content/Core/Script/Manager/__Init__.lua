if Ann.Env.bServer then
	--TODO
end
if Ann.Env.bClient then
	Ann.UIManager = Ann.NewObject("Core.Client.UIManager")
	Ann.HttpManager = Ann.NewObject("Core.Client.HttpManager")
end
Ann.EventManager = Ann.NewObject("Core.Both.EventManager")
Ann.SceneManager = Ann.NewObject("Core.Both.SceneManager")

Ann.Log("Ann Core module init finished")
