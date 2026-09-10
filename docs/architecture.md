# 项目架构

本文档描述项目当前需要长期保持的架构边界和模块职责。

它不记录开发历史，也不尝试复制所有实现细节。能够通过代码直接判断的细节以代码为准；能够机械验证的约束应优先由 `tools/verify_project.sh` 和测试保证。

## 总体结构

项目按“应用组合根 → 功能模块 → 中立契约 / 通用基础设施”组织。

```text
src/app/                     应用启动、路由、依赖装配
    │
    ├── src/intro/           启动流程
    ├── src/title/           Title 页面与菜单
    ├── src/appreciation/    相册、音乐、回忆与语音鉴赏
    ├── src/adv/             ADV 表现与媒体适配
    ├── src/save_load/       可被 Title / ADV 复用的存读档功能
    └── src/settings/        设置功能
             │
             ├── src/scenario/   剧本运行时及跨功能契约
             ├── src/core/       通用基础设施与持久化
             └── src/ui/         无业务语义的共享 UI / layout
```

核心目标是避免功能页面彼此直接依赖。

跨功能行为通过中立数据契约、typed signal 和组合根中的适配器连接。

## 依赖方向

### `src/app/`

`src/app/` 是应用组合根。

`StartupFlow` 负责：

* 创建和持有应用级服务
* 将服务注入具体功能
* 连接跨功能 typed signal
* 决定 Title、ADV、Save/Load、Settings 等页面之间的路由
* 编排跨页面的进入与离开过程

跨模块依赖应尽量在这里完成装配，而不是让功能页面主动寻找其他功能的节点或服务。

功能模块不应为了方便而反向依赖 `StartupFlow` 的具体页面树结构。

### `src/core/`

`src/core/` 存放可独立于具体页面使用的基础设施，例如：

* Save/Profile 持久化
* 原子 JSON 存储
* 音频基础设施
* 输入基础设施
* 其他跨功能底层服务

`src/core/` 不应导入 `title`、`settings`、`save_load` 等功能实现。

如果一个所谓的“通用服务”必须知道具体页面或功能 Scene，它通常不应该位于 `src/core/`。

### `src/scenario/`

`src/scenario/` 是剧本域以及相关跨功能契约的中立位置。

这里负责：

* KRKR instruction/document 数据模型
* 剧本 parser
* 与页面无关的 scenario runtime
* ADV 启动请求等跨功能数据契约

New Game、Continue、Load、回想以及其他进入剧情的入口统一通过 `ScenarioLaunchRequest` 表达启动意图。

发起请求的页面不负责决定最终创建哪个 ADV 页面，也不应直接操作 ADV 内部节点。

### 功能目录

功能自己的 Scene、Control、服务和数据应优先保留在功能目录中。

只有同时满足以下条件的实现才应提升到 `src/ui/` 或 `src/core/`：

1. 已经存在两个或以上真实调用方；
2. 不再包含具体功能的业务语义。

不要为了假设中的未来复用提前建立共享抽象。

## Scene 与脚本职责

固定 UI 结构应尽量由 Godot Scene 表达。

适合保存在 `.tscn` 中的内容包括：

* 固定节点
* 节点层级
* Anchor 与 Container 布局
* 固定覆盖层
* 可复用 UI 组件
* Theme variation
* 稳定资源引用

脚本主要负责：

* 依赖注入
* signal
* 状态同步
* 路由
* 分页
* 数据绑定
* 动画状态协调
* 运行时动态内容

只有数量真正由 manifest、剧本或用户数据决定的节点才应在运行时创建，例如：

* ADV 角色
* 剧情选项
* Album / Memories 数据卡片
* Voice 收藏项

动态节点创建后应立即获得稳定的业务名称。

如果同一帧需要替换同名动态节点，应先将旧节点从父节点移除，再调用 `queue_free()`，避免 Godot 自动生成 `@Node@...` 名称。

固定且可复用的 UI 优先实例化 Scene，而不是通过 `SomeControl.new()` 重新搭建。

## 设计空间与响应式布局

项目美术基准为 1920×1080。

需要使用这一美术坐标系的页面应复用：

* `DesignCanvasPage`
* `DesignViewportLayout`

不要在各功能中重复实现：

* 1920×1080 缩放算法
* Viewport fitting
* aspect-ratio 处理
* 移动端 safe-area 计算

桌面端需要适应不同窗口比例；Android 与 iOS 还必须考虑系统安全区。

复杂页面应优先通过 Godot Container、Anchor 和共享布局基础设施实现自适应，而不是散布大量 viewport 特判。

## UI、Theme 与共享组件

字体、颜色、描边、图标、StyleBox 和通用控件状态应优先通过 Theme 与外部 `.tres` 资源表达。

共享样式放在：

```text
assets/themes/ui/
```

只属于某一功能的样式留在对应功能目录或对应 Theme 子目录。

共享 UI 只负责通用交互，不应偷偷承担业务状态。

普通确认流程应复用：

```text
src/ui/confirmation_overlay.tscn
```

设置重置、标题退出、返回标题和存读档使用同一个确认层，统一采用原设置弹窗的横向背景、模糊效果与文字按钮。通用动画和图片复选框位于 `src/ui/`。

确认层负责模态焦点约束以及关闭后的焦点恢复；调用方负责提供业务文字和解释结果。可选的“始终询问”只发出状态信号，由调用方持久化。美术与内容通过 `DesignCanvasPage` 适配窗口和移动端安全区。

不要重新引入已经移除的、纯依赖预烘焙图片实现整套 Save/Load chrome 的方案。固定 Save/Load UI 由 Scene 与 Theme 拥有。

## 输入与焦点

项目需要同时支持：

* 键盘
* 鼠标
* 手柄
* 触摸

剧情语义输入统一使用：

```text
vn_advance
vn_cancel
vn_confirm
```

功能页面不应建立与这些语义重复的平行输入规则。

交互页面必须提供合理的初始焦点。

模态窗口需要：

1. 打开时限制焦点在模态区域；
2. 关闭时恢复此前仍然有效的焦点。

Godot 默认的 touch-to-mouse emulation 是正常运行路径的一部分。

项目会过滤 `InputEvent.DEVICE_ID_EMULATION` 产生的合成鼠标事件，避免一次触摸同时按触摸和鼠标路径触发两次操作。

## Title 与鉴赏

`src/title/` 只拥有 Title 页面、菜单和 Title 专属表现组件。

`src/appreciation/` 是与 Title、Settings、Save/Load 平级的独立功能，拥有：

* Album
* Music
* Memories
* Voice

固定页面结构由 Scene 持有；manifest 决定的数据卡片可以动态生成。

Title 只发出用户选择的路由意图，不直接导入或实例化 Appreciation。`StartupFlow` 负责创建 `AppreciationScreen`、注入 Profile/Save 服务并连接返回与剧情请求。

从 Title 打开 Appreciation 时，`StartupFlow` 必须像 Settings 与 Title Load 一样将其组合为 overlay：同一个 Title 实例保留在底层持续渲染，隐藏交互 chrome 并暂停输入，Appreciation 通过根视口 `BackBufferCopy` 与共享模糊材质显示实时背景。关闭 overlay 后恢复原 Title 实例、输入与调用前焦点；Appreciation 不应再携带静态 Title 背景或以整页背景遮住该实时模糊层。

Appreciation 不拥有 Title、Settings 或 Save/Load 的实现，也不应导入这些平级功能目录。鉴赏内部的数据模型、页面、UI 组件与语音收藏服务均保留在 `src/appreciation/`。

Title 不拥有通用 Save/Load 实现，也不应该把 Save/Load 变成自己的内部页面。

全局解锁进度属于持久化 Profile，而不是某一个临时页面实例。读入旧存档时，不应撤销用户已经在其他流程中获得的全局解锁。

Voice 收藏拥有独立的 `VoiceCollectionService`，不与 autosave 生命周期绑定。
ADV 只发出中立的语音收藏意图；`StartupFlow` 按需创建该服务，并在进入语音鉴赏时注入同一实例。

## Scenario 导入边界

源工程中的 KRKR 数据属于导入源，而不是产品运行时依赖。

`tools/import_krkr_scenarios.sh` 负责将源 `.ks` 文件转换为项目内部使用的 UTF-8/LF 文本。

当前导入覆盖全部 306 个源剧本。

产品运行时只接受转换后的 UTF-8 剧本，不应增加：

* UTF-16 runtime fallback
* TJS runtime parser
* 对源工程目录的直接读取

`tools/import_krkr_adv_assets.sh` 负责导入这些剧本实际需要的媒体以及固定 ADV 界面素材。

必须从源 TJS 提取的数据应在导入阶段转换为项目自己的规范化格式，而不是让运行时继续依赖 TJS。

这一边界使 KRKR 兼容复杂度停留在可重复执行的导入工具中。

## Scenario Runtime 与 ADV

`src/scenario/` 的 runtime 负责剧情状态机语义，并保持与具体 Godot 页面和媒体节点解耦。

它处理的剧情边界包括：

* 对话与 Hitret
* label / script 切换
* 选项
* local / global flags
* 条件控制
* wait
* 回想入口
* 外部影片暂停点

具体视觉与媒体执行由 `src/adv/` 适配。

### `AdvScreen`

`src/adv/adv_screen.tscn` 是完整 ADV 页面。

固定层级由 Scene 持有，包括：

* Stage
* 对话
* 游戏菜单
* Choices
* History
* Movie
* Audio
* 其他固定覆盖层

`AdvScreen` 负责页面级协调，例如：

* Scenario runtime 与表现层之间的连接
* Auto / Skip 推进
* 系统菜单状态
* 剧情等待
* Save/Load 与 Settings 集成
* 页面退出与路由交接

它不应把固定界面结构重新改成脚本动态创建。

### `AdvDialogueView`

`src/adv/components/adv_dialogue_view.tscn` 拥有单个对话框的视觉和局部交互。

它负责：

* 对话文本
* 姓名显示
* 头像
* 对话框外观
* reveal 动画
* 对话框自身的显示/隐藏动画
* 与对话框有关的局部输入信号

它接收调用方解析完成后的文本、资源和外观数据。

`AdvDialogueView` 不拥有：

* Scenario runtime
* StageDirector
* SettingsRepository / SettingsModel
* SaveService
* 游戏音频流程
* Auto / Skip 的推进决策

Auto / Skip 是否推进下一条剧情属于 `AdvScreen`。

对话框动画中的临时位置或透明度也不应反向污染需要保存的稳定静止状态。

### 资源解析

ADV runtime 通过项目内 resolver 查找 `res://` 资源。

源资源 ID 的兼容处理属于 resolver / import boundary，不应改变 Scenario 状态机本身的语义。

缺少媒体资源时应将其视为媒体解析问题，而不是悄悄改变剧情执行路径。

## Settings

`src/settings/` 拥有完整设置功能。

当前主要分为：

* Display
* System
* Audio

`SettingsPage` 是完整设置状态和设置页面协调的主要来源。

`SettingsScreen` 负责与 `SettingsRepository` 的持久化连接。

应用级的 Settings 集成由组合根完成，而不是由 Title 或 ADV 直接拥有另一个功能的内部实现。

ADV 对话框上的音量与文本快捷入口属于 ADV 自身的轻量悬浮控件，不切换到完整 Settings route。它们复用 `SettingsModel` 的值语义，并通过注入给 `AdvScreen` 的 `SettingsRepository` 做即时预览与持久化；不得另建一份设置文件或绕过设置仓储。

### Settings ADV Preview

Display 页面中的 ADV 预览必须保持轻量。

预览使用：

```text
src/adv/preview/adv_settings_preview.tscn
```

并复用真实的：

```text
AdvDialogueView
```

它只负责演示与设置直接相关的视觉效果。

预览不应重新实例化完整 `AdvScreen`，也不应引入：

* Scenario runtime
* StageDirector
* Save/Load
* 游戏音频流程
* Choices
* History
* Movie
* 游戏菜单

预览使用固定样本，不读取当前游戏剧情状态。

游戏与预览之间可以共享纯外观解析，例如 `AdvDialogueAppearance`，但共享外观层不应反向拥有 Settings。

当前缺失的源字体统一使用项目已有字体 fallback；不要通过只在预览里替换字形来伪装成完整字体支持。

## 路由与页面交接

跨功能路由由 `StartupFlow` 编排。

页面本身负责表达属于自己的离场/进入动画语义；组合根负责决定什么时候创建或移除下一页面。

不要为了简化代码而在同一帧直接销毁旧页面并暴露新页面，从而绕过既有的视觉交接过程。

New Game 与读档属于不同的视觉路由语义，应保持各自的 transition contract。

Settings 作为覆盖层运行时，也应由应用组合层负责其背景与当前 route 的关系，而不是让 Settings 反向知道 Title 或 ADV 的内部节点。

具体 Tween 时间属于实现和视觉测试，不属于长期架构 contract，除非未来明确将某一时序提升为协议。

## Save / Load 与持久化

运行时用户数据必须写入：

```text
user://
```

不得写入 `res://`。

### 数据所有权

当前持久化所有权为：

```text
SaveService
├── SaveData
└── ProfileData

SettingsRepository
└── Settings

VoiceCollectionService
└── Voice favorites
```

这些模块共同复用：

```text
AtomicJsonStore
```

不要在功能模块中复制 `.tmp` / `.bak` / atomic replace 等持久化实现。

需要改变存储位置的测试通过服务公开接口进行隔离。

UI 和路由代码不得依赖生产环境硬编码路径，应通过服务提供的 accessor 获取实际路径。

修改持久化数据结构时必须考虑：

* schema migration
* 老版本数据
* `.bak` recovery
* atomic write
* 测试隔离存储

### Save / Load 页面

`src/save_load/` 是独立功能。

它不能依赖 `src/title/` 或 `src/appreciation/`。

Title 可以配置 Load 行为，ADV 可以为 Save/Load 提供当前剧情快照，但二者都使用同一份 Save/Load 功能。

当前 SaveService 提供：

* 900 个普通存档槽
* 9 个快速存档
* 独立 autosave

大量手动槽位不能通过同时创建 900 个完整卡片节点实现。

Save/Load 页面使用有限数量的可复用卡片作为可视区域池，并根据业务索引重新绑定内容。

修改 SaveData 时必须保持剧情恢复所需的场景位置、剧情状态和表现状态的一致性。读档所需的导航检查点也必须在剧情恢复继续推进之前完成恢复。

## 资源与媒体

大体积二进制资源由 Git LFS 管理。

当前包括：

* PNG / JPEG / WebP
* OGG / WAV
* OGV
* TTF / OTF / fontdata

具体规则以 `.gitattributes` 为准。

不要因为普通代码任务：

* 批量重新编码媒体
* 重命名大量源素材
* 重写 Git LFS 历史
* 改变资源 manifest 数量
* 删除字体 license / attribution

Godot runtime 视频使用项目可解码的 OGV，而不是在 manifest 中直接引用 MP4。

资源导入时尽量保持源 ID、文件名和 loop metadata 的稳定，避免让运行时代码承担额外映射复杂度。

## Editor 与 `@tool`

需要编辑器预览的脚本可以使用 `@tool`。

但 editor execution 与 runtime execution 必须保持明确边界。

如果一个 `@tool` 父节点在 editor `_ready()` 中调用子 Scene 的脚本 API，则：

* 子脚本也必须支持 `@tool`；或
* 父节点必须避免在 editor 中执行该调用。

不要加入“只要打开 Scene 就会修改项目数据”的 editor side effect。

## 新功能放置原则

新增代码时优先按照以下规则判断位置：

| 类型                | 建议位置                                |
| ----------------- | ----------------------------------- |
| 新功能页面             | `src/<feature>/`                    |
| 功能内部组件            | `src/<feature>/components/` 或 `ui/` |
| 跨功能数据契约           | 中立顶级域目录，例如 `src/scenario/`          |
| 无业务语义且已有多个调用方的 UI | `src/ui/`                           |
| 通用基础设施            | `src/core/`                         |
| 应用级依赖装配           | `src/app/`                          |
| 固定 UI             | `.tscn` Scene                       |
| 数据驱动重复项           | 运行时创建                               |
| 可复用视觉样式           | Theme / `.tres`                     |
| KRKR 数据转换         | `tools/` 导入边界                       |

先寻找已有组件和服务，再增加新抽象。

## 验证

迭代过程中优先执行与当前修改相关的 targeted tests。

具有实质影响的实现修改在交付前运行：

```bash
./tools/verify_project.sh
git diff --check
```

如果 Godot 不在 `PATH`：

```bash
GODOT_EXECUTABLE=/path/to/godot ./tools/verify_project.sh
```

`tools/verify_project.sh` 是可机械检查仓库约束的主要入口。

它负责的规则不需要再在 README 或本文档中逐条复制。

视觉 UI 修改在适用时应检查实际渲染结果。专项截图入口位于：

```text
tests/visual_capture.gd
```

Title 云层的专项视觉验证见：

```text
docs/cloud_loop_validation.md
```

## 文档维护原则

三类文档承担不同职责：

```text
README.md / README.zh-CN.md
    面向项目访问者：项目是什么、当前功能、如何运行和验证

AGENTS.md
    面向 coding agent：少量无法安全推断、且违反后代价较高的仓库规则

docs/architecture.md
    面向开发者：长期模块边界、所有权和跨功能 contract
```

当实现细节发生变化但架构边界不变时，不需要更新本文档。

只有在引入或修改长期存在的：

* 模块边界
* dependency direction
* 数据所有权
* persistence contract
* route contract
* 共享 UI ownership
* import/runtime boundary

时才应同步更新本文档。

如果新的架构规则可以被机械判断，也应同时考虑将对应检查加入 `tools/verify_project.sh`。
