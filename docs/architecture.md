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

## 存读档页面与存储契约

- 保留新项目视觉和固定场景，VBoxContainer 分配标题/页脚留白，内容高 811，页脚下边距 12。两侧共用 `assets/themes/ui/frame.tres` 和 25 px 内边距，外边距/面板间距 18。
- `SaveSlotList` 是场景拥有的原生 ScrollContainer，四列、三行可视区、14 px 滚动条间隔。仅实例化五行卡片作为虚拟池，滚动时重新绑定业务索引；只为可见/缓冲槽位加载存档和缩略图，方向键导航能跨越池边界。
- `SaveService` 提供 900 手动槽、9 个按序号轮换的快存文件及独立自动存档，来源是原项目 Status.tjs 的 10×10×9 与九条快存。UI 按手动、快速、自动顺序展示，存档模式仅展示手动槽。序号和剧情同文件原子写入，避免独立索引与数据失步。
- SaveData schema 6 将原版字段 `comment` 作为唯一显示及编辑的存档文本，并用 `comment_edit` 标记手动替换；ADV 以“可见角色名＋当前对话”初始化，编辑上限 128 字。schema 5 的 `autosave_meta.label` 迁移到 `comment`，原有非空备注优先保留并标为已编辑。960×540 缩略图由 ADV 的请求级 `AdvBackgroundPreview` 场景离屏渲染背景相机快照（含滚动背景，不含 GUI／独立角色层），SaveService 压缩并与剧情一次写入 AtomicJsonStore。复制保留时间、状态和图像；目标解锁；移动提交目标后才删除来源。锁定保护覆盖/移动/删除，旧版数据和 `.bak` 恢复继续可用。复制、移动、删除属于页脚级管理操作；锁定入口只存在于非空手动存档卡片右上角。
- 读取操作位于卡片图片中央，仅选中的非空槽位显示且可点击，键盘使用 vn_confirm。复制和移动先保存独立来源快照，再选手动目标，由共享 ConfirmationOverlay 确认；恢复焦点时不会误提交传输。
- Settings 与 Save/Load 共用中立 `src/ui/page_tab_button.gd`、`text_action_button.gd`、背景模糊和蒙层。缩略图铺满图框，左侧用 AspectRatioContainer 保持 16:9；图片与空预览使用相同 10 px 圆角遮罩；Theme/外部 StyleBox 定义外观。
- `tests/save_load_contract_test.gd` 覆盖容量、快存排序/轮换、图片与备份一致性、复制/移动及锁定，集成在项目验证脚本中。

- 标题入口的读档由 StartupFlow 直接在 OverlayHost 装配 SaveLoadPage，保留活动 Title；退出用与 Settings 相同的 0.30 秒淡出／18 px 下移，再调用 Title 的 play_subscreen_return 并恢复焦点。切换剧情路由必须销毁该覆盖层。TitleFeatureScreen 的 Load 适配继续供独立预览和契约使用。

- SaveLoadPage 入场复用设置页的 0.30 秒三次缓出淡入及 18 px 上移；提前关闭会取消入场 Tween，再从当前状态退场。
- 设置与读档入口调用 TitleScreen.hide_for_subscreen 立即隐藏标题菜单／Logo；play_subscreen_exit 保留，鉴赏等其他路由仍可使用原动画。返回继续调用 play_subscreen_return。

- Album、Memories、Music、Voice 各自仍是 `DesignCanvasPage` 场景，但固定鉴赏 chrome 统一实例化 `src/ui/page_title.tscn` 与 `src/title/content/appreciation_navigation.tscn`。`TitleFeatureScreen` 只负责装配 manifest/profile/service 和在四个目录页之间切换；底部导航不复制到控制脚本中。背景使用不含烘焙标题的 `appreciation_landscape.png`，左上标题完全由与 Settings 共用的 PageTitle 持有。
- Album 与 Memories 按源 HD 坐标使用单排六个 142×58 角色标签、4×2 个 430×250 卡片和 12 px 间距。锁定项保留格位与第三帧锁定外观，但运行时不加载缩略图、不创建内容标题、不可获取焦点；页数仍由完整 manifest 决定。翻页 Tween 只移动卡片 Grid，角色标签、两侧箭头和底部导航保持不动。
- Music 以原版顺序按列从上到下填充三列七行，并按 `bgm_hitbox.png` 的 hover／idle／selected 状态顺序渲染；再次选择当前曲目会停止播放。Voice 保留左侧预览、右侧四列三行的空槽与收藏数据模型，未写入收藏时不制造示例内容。

- 桌面与移动目标统一使用 Godot Mobile 渲染器；验证脚本也必须使用 Mobile，避免只在 Compatibility 路径通过测试。

- TitleMenuButton 是场景拥有的原生 Button，通过 Canvas 绘制 Xiaolai 字形、逐字倾斜方块及英文副标题；文案和方块角度在实例中序列化，字体／颜色／尺寸使用 Theme。Title 场景不再引用 QD-01 至 QD-10 菜单贴图或 AtlasTexture，原素材保留。
- `src/scenario/route_progress.gd` 是 ADV 与 Title 共用的中立线路进度契约：结局剧本仍负责写入通关 Flag，契约集中描述五条线路对应的 Title 角色、Staff Roll 解锁 Flag 与视频。`ProfileData` 将这些全局解锁按单调进度合并，旧存档可以补回缺失的 profile Flag，读取任何存档都不会撤销其他线路已经获得的 Bonus 内容。
- 全局帧率使用 Godot 原生 `application/run/max_fps=60`。Title 的树木背景与 TitleCloudField 作为 `title_screen.tscn` 的直接子场景放在主 Viewport 中，随主循环更新；不再使用独立缓存 SubViewport 或 Title 专用刷新率。
- TitleCloudField 在 Title 主 Viewport 中位于固定 Background 之上，只拥有一个全屏 ColorRect。材质 `title_perspective_clouds_material.tres` 使用 `title_cloud_radial_atlas.png`，按角度和对数半径对整张纹理做放射映射；汇聚位置移至设计坐标 (1280, 950.4)，靠近山脊的路线末段逐渐淡出。参数均可在 Inspector 调整。旧云带图集与提取工具保留为历史实验资源，Title 不再引用，也不创建单云实例或重生。
- `title_cloud_field.gd` 为主流动和轻微云形扰动分别维护局部相位时钟，在各自完整周期上取模；不读取全局 Shader 时间，因此变速、暂停、长时间运行和独立 Title 实例均不发生全体跳回。静态编辑器预览使用材质 phase；运行中隐藏或 SceneTree 暂停时停止推进。资源设置 local_to_scene，避免共享动画状态。
- `title_tree_sway_background.tscn` 封装 Title 背景和树木摆动材质。由 PSD 树木层生成的权重遮罩将位移限制在树冠，并沿高度把树根权重降至零；山体、地面和无关天空像素保持静止。`title_tree_sway_background.gd` 使用场景实例局部相位，避免共享状态和全局 Shader 时间回绕。
- 放射投影与 `sky_mask.svg` 都使用 Background 的 cover 裁切坐标。天空遮罩由 `tools/assets/build_title_sky_mask.py` 从当前无云底图的绘画边界提取成矢量轮廓，使云沿山脊进入遮挡并排除树和草地；Shader 将遮罩边缘向山树内部延伸 6 px，避免过滤后在云和前景之间留下亮色空隙。它是当前背景的近似遮罩，换底图时必须重新生成并检查树梢。放射云图集的 mipmap/Alpha 边界导入配置作为唯一 `.import` 例外保留，确保全新导入也有相同的远处缩小过滤。
- `tests/cloud_test.tscn` 复用 DesignCanvasPage 检查原始垂直循环；`tests/cloud_radial_test.tscn` 复用 TitleCloudField 与背景 cover 检查实际放射效果，不装配菜单或服务。两类 GUI 截图脚本和 `title_cloud_field_test.gd` 分别验证可见结果、循环相位、独立材质与时钟行为。详见 `docs/cloud_loop_validation.md`。
