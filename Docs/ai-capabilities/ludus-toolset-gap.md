# UE6 官方 MCP / Toolset 启用配置与 Ludus 能力盘点

> 数据基准：本机 `D:/learning/AnnBuildTools/AnnUnrealEngine`，`Build.version` = 6.0.0 / `UE6`。
> 机器可读清单：[`toolset-inventory.yaml`](toolset-inventory.yaml)，由
> `python Tools/audit_engine_toolsets.py` 从引擎源码生成，`--check` 为漂移门禁。
> 对照对象：[Ludus AI 产品页](https://ludusengine.com/zh#product) 的 12 类 55 项能力。

## 1. 结论

**编辑器写入层不需要从零开发，也不该引入社区 MCP 插件。** UE 6 源码树自带 Epic 官方
`ModelContextProtocol`（MCP server）+ `ToolsetRegistry` + 52 个 Toolset 目录；本工程此前
只通过 `UEAssetLens.uplugin` 软依赖了官方接口，未启用 server 与工具集。本次变更把这条
链路显式打开，并给出逐项能力缺口。

| 指标 | 实测值 |
|---|---|
| Toolset 目录 | 52（50 个含 `.uplugin`，2 个只有残留 DLL） |
| `AllToolsets` 聚合成员 | 42 |
| 有 C++ 声明工具的 Toolset | 40 |
| `UFUNCTION` AI 可调用标注 | 905 处 |
| 去重后唯一工具 | **878**（Read 409 / Write 398 / Execute 28 / 未标注 43） |
| 含 Content 资产的 Toolset | 18（其中 6 个没有 C++ 工具，属资产型工具） |

`EToolAccessMode` 已由 Epic 定义为 `Read / Write / Execute` 并写入
`annotations.accessMode`，供 host 决定调用是否需要确认。因此**权限元数据不用自研**，
需要自研的是"读取该标注并拦截/审批"的 host 策略。

## 2. 本次启用配置

### `Ann.uproject` 新增 5 条

| 插件 | 作用 | 为何不进游戏包 |
|---|---|---|
| `ModelContextProtocol` | Epic 官方 MCP server（HTTP + SSE，spec `2025-06-18`） | `TargetAllowList: ["Editor"]` |
| `ToolsetRegistry` | 工具注册表，`EToolAccessMode` 权限模型 | 同上 |
| `AllToolsets` | 一条聚合，拉起 42 个官方 Toolset | 同上 |
| `CrashDiagnosticsToolset` | 聚合外，对应 Ludus「调试」 | 同上 |
| `GeometryToolset` | 聚合外，对应 Ludus「3D 建模」的资产型工具 | 同上 |

三者官方标记均为 `IsExperimentalVersion: true` / `EnabledByDefault: false`，MCP 与聚合
另带 `NoRedist: true`。`TargetAllowList: ["Editor"]` 由 UBT 的
`PluginReferenceDescriptor` 支持，确保这些模块只进 `AnnEditor`，不进 Game / Client / Server
target；**发布前必须复核打包配置**，不得把 `NoRedist` 插件带入分发包。

### `Config/DefaultEditorPerProjectUserSettings.ini`

新增 `[/Script/ModelContextProtocol.ModelContextProtocolSettings]`，显式固定
`bAutoStartServer=True` / `ServerPortNumber=8000` / `ServerUrlPath=/mcp` /
`bEnableToolSearch=True`。引擎 `BaseEditorPerProjectUserSettings.ini` 本就把
`bAutoStartServer` 设为 `True`，此处固定端口与路径是为了让客户端 URL 可复现。

- 交互式编辑器：启动后监听 `http://localhost:8000/mcp`。
- **Commandlet / headless 会自动跳过自启动**（引擎源码明确为避免与编辑器抢端口），
  需加 `-ModelContextProtocolStartServer`；旧开关 `-StartModelContextProtocolServer`
  已废弃。
- 客户端示例：`claude mcp add --transport http ann http://localhost:8000/mcp`。

### 已存在但不必改的部分

`UEAssetLens.uplugin` 早已声明 `{"Name":"ModelContextProtocol","Optional":true}`，
`FUALEngineMcpTool : public IModelContextProtocolTool` 直接实现官方接口，
`UnrealEditor-UEAssetLensMCP.dll` 已产出。即 4 个自有只读工具本来就挂在官方 server 上。

## 3. 盘点口径与已知限制

1. 工具数来自对 `Toolsets/**/Source/**/*.h` 的静态扫描，匹配
   `UFUNCTION(... meta=(AICallable|AIRuntimeCallable, AIAccessMode=...))`，按工具名去重。
   同名重载只计一次（905 标注 → 878 唯一工具）。
2. **`.uasset` 中注册的 `UToolsetDefinition` 无法静态枚举**。`GeometryToolset`、
   `StateTreeToolset`、`ConversationToolset`、`MetaHumanGenerator`、
   `SequencerAnimMixerToolset`、`MovieRenderPipelineToolset` 这 6 个插件的 C++ 模块是空壳，
   但带 5–15 个 Content 资产，工具很可能由资产注册。清单中记为
   `content_assets`，**必须靠运行时 `tools/list` 才能核实**。
3. `UMGToolSet` / `SemanticSearchToolset` 两个目录**只有 DLL/PDB，没有源码和 `.uplugin`**，
   是引擎构建残留，不可启用、不应计入能力。UMG 能力实际由 `MVVMToolset`(31)、
   `SlateInspectorToolset`(30)、`CommonUIToolset`(15)、`WidgetAnimationToolset`(10)、
   `WidgetStaticAnalysisToolset`(5) 等承接。
4. 覆盖度判定区分「工具底座」与「生成智能」：官方 Toolset 提供的是**确定性的编辑器写操作**，
   Ludus 描述的是「自然语言 → 生成结果」。有写工具 ≠ 能力已达成，中间还缺模型与编排。

覆盖标签：**原生** = 官方已有对应写操作，Agent 只需编排；**部分** = 有相关工具但缺关键环节；
**缺失** = 官方无对应能力，需外部服务或自研。

## 4. 逐项映射（12 类 / 55 项）

### 01 通用开发（6）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| 全项目辅助 | `EditorToolset`(269)、`FileSystemToolset`(9)、UEAssetLens 4 个只读工具 | 部分 | 无"读取一次并实时同步"的项目级索引；UEAssetLens 是按需查询 |
| UE5 问答 | `KnowledgeBaseToolset`(6，未启用) | 缺失 | 只有知识库 CRUD，无 LLM 与知识注入 |
| 项目重构 | `EditorToolset`、`BlueprintToolsets.DiffFunction` | 部分 | 无跨资产引用安全的重构事务 |
| C++ API 查询 | 无 | 缺失 | 需自建引擎 API 索引或接文档检索 |
| 理解项目上下文的对话 | `SlateInspectorToolset`(30)、`EditorToolset` | 部分 | 无统一的关卡/选中 Actor/打开资产上下文聚合层 |
| 项目代码审查 | 无 | 缺失 | 需 Agent + 规则集 |

### 02 蓝图生成（7）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| 复杂蓝图系统 | `BlueprintToolsets`(81)：`AddComponent`、`AddVariable`、`CreateFunction` | 部分 | 系统级设计（背包/对话/存档）靠 Agent 编排 |
| 蓝图分析 | Graph DSL `Read`、`WidgetStaticAnalysisToolset.DescribeWidget` | 原生 | — |
| 将蓝图转换为 C++ | 无 | 缺失 | 需自研转译或放弃 |
| 图表重构 | `AddCommentBox`、`AddFunctionGraph` | 部分 | 无自动整理与行为保持校验 |
| 宏与函数生成 | `CreateFunction`、`AddFunctionParam`、`AddObjectVariable` | 原生 | — |
| 自定义事件与委托 | `AddEvent`、`AddEventDispatcher`、`AddComponentBoundEvent` | 原生 | — |
| 蓝图调试 | `RewindDebuggerToolset`(10)、`AutomationTestToolset`(7) | 部分 | 无跨蓝图节点级错误定位 |

### 03 角色动画（5）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| 角色自动骨骼绑定 | 无 | 缺失 | 外部 UniRig / Blender → Interchange |
| 生成动画 | 无 | 缺失 | 外部生成模型 |
| 非人形骨骼绑定 | 无 | 缺失 | 同上 |
| 动画重定向 | 无 MCP 工具（引擎有 IK Retargeter 功能） | 缺失 | 需补 Toolset 或编辑器脚本 |
| 通过文字编辑动画 | `AnimationAssistantToolset`(4，Sequencer Director)、`SequencerAnimMixerToolset`(资产型，未启用) | 缺失 | 面向 Sequencer 而非角色动作编辑 |

### 04 视觉特效制作（4）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| 生成 Niagara 图表 | `NiagaraToolsets`(56)：`CreateNiagaraSystem`、`AddEmitter`、`AddModule`、`AddRenderer` | 原生 | — |
| 完整特效制作流程 | 同上 + `EditorToolset` 材质工具 | 部分 | 跨 Niagara / 材质 / 参数编排需 Agent |
| 编辑现有粒子系统 | `AddModule`、`RemoveModule`、`ApplyStackIssueFix`、`SetRendererData` | 原生 | — |
| 后期处理设置 | `EditorToolset` 未确认有专用 PostProcess 工具 | 部分 | 需运行时 `tools/list` 核实 |

### 05 材质生成（5）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| 材质实例与参数 | `CreateMaterial`、`SetMaterial`、`SetTextureParameter`、`GetTextureParameter` | 部分 | 共 11 个相关工具，无材质图节点编辑 |
| 完整支持 Substrate | 无专用工具 | 缺失 | — |
| 材质函数制作 | 无 | 缺失 | 官方无 Material Graph DSL（对比蓝图有 Graph DSL） |
| 通过文字编辑材质 | 无 | 缺失 | — |
| 从纹理创建材质 | `TextureGraphToolset`(18)、`ReadTexture` | 部分 | Texture Graph ≠ 材质图 |

### 06 声音设计（4）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| 音乐生成 | 无 | 缺失 | AudioCraft / stable-audio-tools，进程隔离 |
| 音效合成 | 无 | 缺失 | 同上 |
| 环境底音 | 无 | 缺失 | 同上 |
| 音频提示设置 | `MetaSoundToolset`(42)：`AddNodes`、`AddGraphPage`、`BuildToAsset` | 原生 | — |

### 07 图像生成（3）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| 图像生成 | `SceneCaptureToolset`(14) 仅截图/取帧 | 缺失 | ComfyUI / FLUX，注意 GPL-3.0 需进程隔离 |
| 通过文字编辑图像 | `MediaToolset.ReadImageFile` 只读 | 缺失 | 同上 |
| 为 3D 模型重制纹理 | `TextureGraphToolset` 图编辑 | 部分 | 无文字→纹理的生成链路 |

### 08 3D 建模（5）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| 文字转 3D | 无 | 缺失 | TRELLIS / TripoSR / Hunyuan3D，许可需审 |
| 图像转 3D | 无 | 缺失 | 同上 |
| 重拓扑 | 无 | 缺失 | 外部几何处理 |
| LOD 生成 | `GenerateLods`、`GetLodCount`、`SetLodThresholds`、`SetNaniteEnabled` | 原生 | — |
| 资产变体生成 | `EditorToolset.AddCube` / 资产复制 | 部分 | 无生成式变体 |

### 09 调试（1）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| 调试 | `CrashDiagnosticsToolset`(2，已启用)、`RewindDebuggerToolset`(10)、`ConsoleToolset`(9)、`PerfToolset`(10) | 部分 | 缺"结合全项目上下文解释并修复"的推理层 |

### 10 AI Behavior Tree（6）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| Behavior Tree 生成 | `AIModuleToolset`(38)：`CreateBehaviorTree`、`AddComposite`、`AddDecorator`、`AddService` | 原生 | — |
| Blackboard 设置 | `CreateBlackboardData`、`AddBlackboardKey`、`GetAllowedBlackboardKeys` | 原生 | — |
| 自定义 BT 任务 | `BlueprintToolsets` 可建类 | 部分 | 需跨 Toolset 编排 |
| 感知设置 | 未见 AI Perception 专用工具 | 部分 | 需运行时核实 |
| EQS 查询 | `NavMeshToolset`(21) 有 `FindPath`，无 EQS 图编辑 | 缺失 | 需补 Toolset |
| AI 行为调试 | `RewindDebuggerToolset`、`AutomationTestToolset` | 部分 | — |

### 11 PCG 图表（4）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| PCG 图表生成 | `PCGToolset`(33)：`CreateGraph`、`AddNode`、`ConnectNodePins` | 原生 | — |
| 散布系统 | `DrawSpline`、`RunPCGInstantGraph` | 部分 | 密度/坡度/排除规则需编排 |
| 编辑现有 PCG | `AddNode`、`DisconnectNodePins`、`AddSubgraphNode` | 原生 | — |
| 解释 PCG 图表 | 未确认有节点描述类工具 | 部分 | 需运行时核实 |

### 12 UMG 控件（5）

| Ludus 项 | 官方工具依据 | 覆盖 | 缺口 / 动作 |
|---|---|---|---|
| 控件生成 | `WidgetAnimationToolset`(10)、`MVVMToolset`(31) 偏编辑现有 | 部分 | 需确认有无 `CreateWidgetBlueprint` 类工具 |
| 控件逻辑连接 | `MVVMToolset.AddViewModelToWidget` + `BlueprintToolsets.AddEvent` | 部分 | 按钮事件/可见性需跨 Toolset 编排 |
| 数据绑定 | `MVVMToolset`：`AddViewModelProperty`、`GetViewModelConnectionMap` | 原生 | — |
| 控件动画 | `CreateWidgetAnimation`、`SetWidgetAnimationLength`、`FindWidgetAnimation` | 原生 | — |
| 响应式布局 | `WidgetStaticAnalysisToolset`(5) 只读、`SlateInspectorToolset.HitTest` | 部分 | 无自动布局与安全区工具 |

### 汇总

| 覆盖度 | 项数 | 占比 |
|---|---|---|
| 原生 | 13 | 24% |
| 部分 | 21 | 38% |
| 缺失 | 21 | 38% |

**结构性结论**：官方工具在「蓝图 / Niagara / MetaSound 图 / PCG / Behavior Tree / UMG 绑定与动画 /
LOD」这些**结构化图编辑**域基本齐备；缺口集中在两类——① **生成式内容**（文生图/3D/音乐/动画、
自动绑骨、重拓扑），② **项目级智能**（全项目上下文、问答、代码审查、C++ API 查询、蓝图转 C++）。
这两类都不是"再写几个 Toolset"能解决的，需要外部模型服务 + Agent 编排层。

## 5. 真正必须自研 / 外部整合的部分

| 优先级 | 事项 | 供给方式 |
|---|---|---|
| P0 | GameSpec 规格层（玩法域/实体/规则/胜负/输入/UI/关卡/验收断言） | 自研，复用 UEYaml |
| P0 | 玩法模板库（先收敛到 1–2 个可保证成功的域） | 自研 |
| P0 | 审批 / dry-run / diff / 回滚（消费官方 `annotations.accessMode`） | 自研薄层 |
| P0 | 验证闭环（headless 编译 → PIE → 状态快照 → 断言 → 回编排层） | 自研 |
| P1 | 运行时工具审计（`tools/list`），补齐资产型工具清单 | 自研脚本 |
| P1 | 图像 / 3D / 音乐生成服务 | ComfyUI(GPL-3.0 进程隔离) / TRELLIS(MIT) / AudioCraft(MIT) |
| P1 | Agent 编排循环（规划→调用→观察→修正，带预算与断点续跑） | 参考 OpenHands / langgraph，裁剪而非 vendor |
| P2 | 自动绑骨 / 动画重定向 / 重拓扑 / 变体生成 | UniRig + Blender + Interchange |

## 6. 验证方式与实际结果

```bash
# 1) 清单漂移门禁（零第三方依赖）
python Tools/audit_engine_toolsets.py --check

# 2) 启用配置依赖闭包（插件是否存在、传递依赖是否缺失）
python Tools/audit_engine_toolsets.py --check-enablement

# 3) 让 UBT 解析 .uproject 与 target rules（不编译、不校验 C++ 工具链）
dotnet D:/learning/AnnBuildTools/AnnUnrealEngine/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll ^
  -Mode=QueryTargets -Project=D:/learning/AnnBuildTools/Ann/Ann.uproject

# 4) 完整编译（在有合格工具链的环境执行）
D:/learning/AnnBuildTools/AnnUnrealEngine/Engine/Build/BatchFiles/Build.bat ^
  AnnEditor Win64 Development -Project=D:/learning/AnnBuildTools/Ann/Ann.uproject -WaitMutex

# 5) 运行时核实资产型工具：启动编辑器后拉 tools/list
#   initialize -> notifications/initialized -> tools/list
#   endpoint: http://localhost:8000/mcp
```

| 检查 | 本次结果 |
|---|---|
| `--check` | **通过**：inventory 与引擎树一致 |
| `--check-enablement` | **通过**：5 个 Editor-only 启用项，156 个插件依赖闭包，0 个硬缺失 / 0 个可选缺失 |
| `-Mode=QueryTargets` | **通过**：UBT 成功解析工程并写出 `Intermediate/TargetInfo.json` |
| `AnnEditor` 编译 | **未完成**，见下 |

### 编译验证的阻断原因（与本次配置无关）

修改 `.uproject` 会让 UBT **重建 makefile**，从而重新探测 MSVC 工具链；此前 6 次增量编译
因复用缓存 makefile 而未触发该探测，均成功。重建时报：

```
Visual Studio is installed, but is out of date or missing a valid C++ toolchain
(minimum version 14.50.35723, preferred version 14.50.35717).
```

根因是本机 `Engine/Config/Windows/Windows_SDK.json` 要求 `MinimumVisualCppVersion =
14.50.35723`（注释说明 14.50.35717 存在内部编译器错误，14.50.35723 已修复），而本机
MSVC 目录名为 `14.50.35717`；缓存 makefile 里记录的却是注册表/编译器版本
`14.50.35738`，所以增量编译能通过、重建 makefile 不能。`-CompilerVersion=Latest` /
`=14.52.37025` / `=14.50.35738` 三种写法均无法绕过 `HasValidCompiler` 的全局检查。

**修复建议**：通过 VS Installer 把 MSVC 组件更新到目录版本 ≥ `14.50.35723`（本机另有
`14.52.37025`，但超出引擎 `PreferredVisualCppVersions: 14.50.35717-14.50.99999` 范围）。
不建议为绕过校验去改引擎的 `Windows_SDK.json`。工具链修好后重跑第 4 步即可确认
5 条启用项及其 42 个 Toolset 依赖能编译链接。

> 注意：本仓库此前 YAML 改造的 `AnnEditor Win64 Development` 编译是**成功**的
> （`Result: Succeeded`，UEYaml.dll 与三个插件 DLL 全部链接），那次未改动 `.uproject`。

## 7. 硬约束

- 官方 MCP / Toolset **全部 Experimental + `NoRedist: true`**：仅开发期启用，不可随发布包分发。
- 社区插件不作为基线：`chongdashu/unreal-mcp` 代码停更于 2025-04、无 LICENSE 文件（GitHub
  返回 `NOASSERTION`）、自建 TCP 协议与官方 `ToolsetRegistry` 不兼容；`monolith`、
  `Unreal_mcp`、`ue-mcp` 等只取工具清单与实现模式，不 vendor 插件本体。
- Ludus 明确自述「不会替你制作整个游戏」，且支持范围为 UE 5.4–5.8；本工程是 UE 6 源码构建，
  第三方 UE MCP 插件标称版本均落后一个代际。
- 生成式内容依赖 GPU 与模型权重，且需逐个核对许可（ComfyUI GPL-3.0、Hunyuan3D 许可未声明）；
  UEAbilityKit 为 PolyForm 商业许可，生成物分发需合规审查。
