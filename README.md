致力于打造一个通用的游戏客户端框架，欢迎 Fork 、 Star！

## 工程结构

本仓库基于 Unreal Engine **6.0 源码构建**（`EngineAssociation` 指向本地源码树 GUID）。
游戏代码在 `Source/Ann`，核心框架在 `Plugins/AnnCore`。

`Plugins/` 下三个插件是**平级的 git submodule**，各自有独立仓库、独立版本与独立发布包：

| 目录 | 用途 | 仓库 |
|---|---|---|
| `Plugins/UEAssetLens` | 离线资产规格索引与 MCP 检索 | [HUSTJJD/UEAssetLens](https://github.com/HUSTJJD/UEAssetLens) |
| `Plugins/UEAbilityKit` | 基于 GAS 的技能编辑器 | [HUSTJJD/UEAbilityKit](https://github.com/HUSTJJD/UEAbilityKit) |
| `Plugins/UnLuaNova` | Lua / Luau 脚本层（Luau 后端） | [HUSTJJD/UnLuaNova](https://github.com/HUSTJJD/UnLuaNova) |

`Plugins/AnnCore` 是工程内插件（受本仓库跟踪），依赖 `UnLuaNova`。
UE 6.0 的 UBT 与编辑器会递归扫描 `Plugins/` 下的 `.uplugin`，因此
`UnLuaNova/Plugins/UnLuaNova/UnLuaNova.uplugin` 等内嵌插件可被自动发现；
具体启用状态以 `Ann.uproject` 的 `Plugins` 数组为准。

## 首次克隆 / 初始化

```bash
# 推荐：一次性拉全（UnLuaNova 内部还有 Lua / Luau 等嵌套子模块）
git clone --recurse-submodules https://github.com/HUSTJJD/Ann.git
```

已经普通克隆的，执行：

```bash
git submodule update --init --recursive
```

Windows 下可直接运行 `Setup.bat`（同时安装 Git hooks 与初始化子模块）。
升级插件版本后请提交新的 gitlink：

```bash
git -C Plugins/UEAssetLens pull --ff-only
git add Plugins/UEAssetLens
git commit -m "chore: bump UEAssetLens"
```

> 子模块指针是**锁定 commit**，不是分支跟踪。CI / 打包环境务必使用
> `--recurse-submodules`，否则 `AnnCore` 对 `UnLuaNova` 的依赖会解析失败。

## 引擎与脚本层

- 脚本层已从旧 `UnLua` 迁移到 `UnLuaNova`（`LuaBackend=Luau`、数据驱动绑定），
  配置见 `Config/DefaultUnLuaNova.ini`。
- `Config/DefaultGame.ini` 的 `DirectoriesToAlwaysStageAsUFS` 以 `<Project>/Content`
  为基准，列出工程业务 Lua 目录与插件脚本目录，打包时不可删。
- 编译：`Engine/Build/BatchFiles/Build.bat AnnEditor Win64 Development -Project=<path>/Ann.uproject -WaitMutex`。
