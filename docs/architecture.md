# 项目架构

本项目按“组合根 → 功能模块 → 通用基础设施”组织。依赖只能沿下图向下，功能模块之间通过中立契约通信，不直接引用对方的页面实现。

```text
src/app/                     启动、路由、依赖装配
    ├── src/intro/           启动画面
    ├── src/title/           标题页与鉴赏功能
    ├── src/adv/             ADV 场景表现与媒体适配
    ├── src/save_load/       可由 Title/ADV 配置的存读档功能
    ├── src/settings/        设置功能与 SettingsRepository
    └── src/scenario/        ADV 启动请求等跨功能契约
             │
             ▼
src/core/                    存档、音频、输入、原子持久化
src/ui/                      不含业务语义的共享 UI/layout
```

## 依赖规则

1. `src/app/` 是组合根：创建服务、连接跨模块信号、决定页面路由。
2. `src/core/` 不得导入 `title`、`save_load`、`settings` 等功能目录。
3. 跨功能数据放在中立目录。例如 Title 只发出 `ScenarioLaunchRequest`；`StartupFlow` 决定进入 `src/adv/`，Title 不引用 ADV 页面。
4. 功能专属弹窗、控件和服务留在功能目录；只有具备两个以上真实调用方且不含业务语义时，才提升到 `src/ui/` 或 `src/core/`。
5. 持久化按数据生命周期拆分：`SaveService` 只负责存档/profile，`SettingsRepository` 只负责设置，语音收藏独立于 autosave；三者共享 `AtomicJsonStore`。
6. `src/save_load/` 不导入 Title 实现；Title 与 ADV 都通过 `configure(...)` 和 typed signal 使用同一页面。

## KRKR 与 ADV 边界

- `tools/import_krkr_scenarios.sh` 把参考工程的 306 个 UTF-16LE `.ks` 文件复制并转换为 UTF-8/LF；运行时解析器只接受 UTF-8，编码兼容不进入产品代码。
- `tools/import_krkr_adv_assets.sh` 只导入这 306 个 UTF-8 剧本实际引用的媒体及固定 ADV 界面素材；完整素材覆盖测试负责阻止缺图、缺音频或缺转场规则进入运行时。导入阶段还会将 `CgSetupInfo.tjs` 中的背景环境色调归一化为 UTF-8 CSV，运行时不读取 TJS 或 UTF-16 源文件。
- `src/scenario/` 持有跨功能的 instruction/document/parser/runtime，不引用具体页面或媒体节点。运行时在 Talk/Hitret、选择、等待、影片等边界暂停并发出 typed signal。
- `src/adv/adv_screen.tscn` 固定持有舞台、菜单、选项/履历/影片覆盖层和音频播放器，通过 `VisualCanvas/DialogueView` 普通实例引用 `components/adv_dialogue_view.tscn`；不使用 Editable Children，也不访问组件内部路径。脚本只协调状态并创建剧本数量决定的角色和选项。
- `AdvDialogueView` 独立持有 `MessagePanel/MessageColumn` 的文字、姓名图、头像与隐藏按钮，保留原坐标、层级及 Theme variation；每个实例复制自己的框体 StyleBox。调用者解析设置、独白语义及资源后传入文本/贴图/颜色/字号/透明度；组件不引用 runtime、StageDirector、SettingsModel、存档或音频。
- 单句 reveal Tween、完成/取消、保留进度的实时变速，以及淡入淡出和手动下滑动画由 `AdvDialogueView` 管理；`reveal_finished` 只通知一次，是否 Auto/Skip 推进由 `AdvScreen` 决定。隐藏按钮只发出 `hide_requested`，框体 GUI 事件只透传给调用者解释。`set_interactive(false)` 禁用组件操作；覆盖层用 0 秒动画同步隐藏/恢复。
- `AdvScreen` 保留系统菜单动画与剧情等待的协调；存档字段 `message_frame_type/position/visible/alpha` 不变，通过组件的布局、状态读取与恢复 API 传递，不保存组件内部 Tween。永久 `set_frame_position` / `apply_frame_type` / `restore_frame_state` 同步当前位置与静止位置；动画只临时偏移，不反向采样成静止状态，取消动画也不能留下半透明的静止框。
- 设置预览由 `StartupFlow` 创建 `src/adv/preview/adv_settings_preview.tscn`，不再实例化完整 `AdvScreen`；后者已移除所有 preview-only API/分支。轻量预览只持有固定 `EA01E` 背景、正常实例化的 `AdvDialogueView` 和单个 one-shot `ReplayTimer`，直接复用既有姓名图与头像资源；不得依赖 runtime、StageDirector、音频、存档、选项、履历、影片或游戏菜单。
- Display 的 `install_preview(Control)` 只负责视觉承载，不保存预览设置或广播私有设置更新信号，也不反向导入 ADV。由于 CanvasItem 显隐不跨 SubViewport 传播，宿主同步注入 Control 的 `visible` 属性；具体演示启停属于 `AdvSettingsPreview`。保留视口 1920×1080、10 px 内边距及圆角裁切。只读输入由 `gui_disable_input`、无焦点控件及 `AdvDialogueView.set_interactive(false)` 共同保证，包括 RichTextLabel 内置滚动条。
- `SettingsPage` 是三个页签完整设置的唯一来源；组合根在创建预览时连接一次 `settings_preview_changed → apply_settings`，预先准备或重新配置只更新状态，不重复连接。原有 `SettingsScreen → SettingsRepository` 转发保持不变；重新配置及保存失败回退广播完整恢复快照，不重新提交。Title 和游戏入口永远使用同一固定样本，不能捕获或接收当前游戏演出、台词、镜头、选项或 SaveData。
- 预览复用对话组件 reveal Tween 演示 `message_speed`，实时变速保留已显示字符；完成后用单个 Timer 等待 `auto_speed` 毫秒，再重播固定长台词。等待中修改自动速度只作用于下一次等待；0 毫秒等待安排到下一帧。隐藏 Display 或 Settings 时取消 reveal 并停止 Timer，显示时从零重播，不能在后台维持无限循环。
- `AdvDialogueAppearance` 只共享游戏／预览的已读颜色和字体资源解析，不持有 Settings。六个源字体 ID 当前仍统一回退到既有 Xiaolai 字体，因为源字体族尚未导入 Godot；不能用预览专用字形伪装为已完成字体切换。对话框各自复制 StyleBox，底图透明度不能通过共享资源污染游戏，也不能使文字与头像变淡。无关音量、确认选项、Auto/Skip 锁等设置只随完整快照传递，预览不为它们添加行为。
- `SaveData` 持久化源 `_stackSelect`/`_logSaveInfo` 对应的选项导航检查点；读档必须在恢复首个对话并写自动存档之前恢复该栈，确保“上一选项”不会因读档丢失。
- `src/adv/adv_asset_resolver.gd` 只解析项目内 `res://` 资源，按不区分大小写的源 ID 复用 event、BGM 和 video 目录。缺失资源不改变 scenario 状态机语义。

## Scene 与脚本的职责

- 固定节点、布局、层级、主题 variation 和可复用弹窗由 `.tscn` 持有，可在编辑器和 Remote Tree 中直接检查。
- 路由级覆盖层由 `StartupFlow/OverlayLayer` 的独立 `CanvasLayer` 承载；ADV 内部舞台、消息框、系统菜单和模态窗口使用场景中明确的层级区间，不能依赖节点添加顺序覆盖源剧本的角色 order。
- 路由交接由 `StartupFlow` 编排、由离场页面执行自身语义动画：New Game 让 Title 淡到黑色 `RouteBackdrop` 后才创建 ADV；ADV 空场及首帧转场快照也使用同一黑底，首句对话框/菜单复用消息显隐逻辑做 300 ms 淡入，自动存档先保存完整显隐状态，不能保存动画半透明值。Continue/Title 侧 Load 则独立使用场景化的蓝色 `FRM_0501` `LoadTransitionCover`，按源 `BeginLoad` 300 ms 覆盖、遮挡时恢复、`EndLoad` 500 ms 揭示的顺序交接，不把这张蓝图当作 New Game 的窗口底；ADV 先结束选项、淡出自身 UI/音频并完成黑场后才创建 Title。路由不得为了方便而在同一帧直接替换这两个页面。
- 脚本负责依赖注入、信号、状态同步、分页和数据驱动的重复项。
- 运行时只生成数量取决于 manifest 或用户数据的节点，例如相册卡片、曲目、回忆与收藏项。
- 动态项必须使用稳定业务名称；刷新列表时先从父节点移除旧项，再 `queue_free()`，避免同帧重名。
- 1920×1080 美术坐标页统一复用 `DesignCanvasPage` / `DesignViewportLayout`，不要在页面中复制缩放与安全区算法。
- 通用确认框复用 `src/ui/confirmation_overlay.tscn`；它负责 modal 焦点和关闭后的焦点恢复，调用方只提供文字并处理 typed signal。

## 新功能放置清单

- 新页面：`src/<feature>/`，入口场景与控制器放在功能根目录，子页放 `pages/`，功能控件放 `ui/` 或 `components/`。
- 新数据契约：若只服务一个功能，留在功能目录；若跨功能，放入中立的顶级域目录。
- 新存储：先明确生命周期和所有者；复用 `AtomicJsonStore`，不要复制 `.tmp/.bak` 逻辑。
- 新固定 UI：优先场景序列化；只有 manifest/用户数据列表才在脚本中构建。
- 新全局依赖：在 `StartupFlow` 装配并通过 `configure(...)` 注入，不在页面中自行查找全局节点。

## 资源与验证

仓库通过 `.gitattributes` 让后续新增或修改的 PNG、音频、视频和字体进入 Git LFS。该配置不会重写既有提交；如需回收历史体积，应在独立维护窗口执行并协调所有协作者重新同步仓库。

提交前运行：

```bash
./tools/verify_project.sh
```

脚本会先检查目录边界、Save/Load 场景所有权、共享确认层、内容 manifest 和关键资源。触摸转鼠标使用 Godot 默认值，因此配置缺省合法、显式 `false` 会失败。如果能找到 Godot，还会继续执行编辑器导入及无头烟雾/契约测试；否则会明确报告只完成了静态检查。
