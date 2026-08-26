# 缘之空重制版 · Godot Title 迁移

本项目把 `yosuga-no-sora-remake` 的启动片段和 HD Title 鉴赏页迁移到 Godot 4.7.1。运行时只依赖强类型 GDScript 与 Godot 原生 Control/Resource，不使用 C#，便于 Windows、macOS、Android、iOS 共用代码。

## 当前范围

启动顺序与原工程一致：

1. 播放 5 秒 Sphere 品牌视频；1.5 秒时随机播放一条品牌语音。
2. 警告页淡入 1 秒，停留 8 秒，再通过 1 秒白场过渡离开。
3. Title 页由白场揭示 1 秒，菜单同时淡入 0.5 秒，播放随机标题语音与循环 BGM。若存在自动存档，会显示“继续”；读取页列出自动存档和 20 个手动槽并支持选择/删除确认，环境设定持久化完整的 Audio/Screen/System 项，音量拖动实时预览并在结束/短暂 debounce 后写入。

Title 的 Bonus 已按源 HD 信息架构重建，而不是一个文字占位列表：

- Album：源 `CgModeList` 前六组，79 张卡片、214 个差分；六个角色页签、每页 4×2 网格、翻页、锁定状态、真实 `event_1920` PNG、全屏查看器和左右差分切换。
- Music：源清单 21 首，三列网格；真实 OGG 播放、停止、切歌，BGM03–BGM21 使用 `.sli` 循环点。
- Memories：24 条（18 条剧情回想、开场视频和 5 条 Staff Roll）；视频使用项目内 OGV，可播放/停止，剧情回想发出真实的 `ScenarioLaunchRequest`，并明确提示“ADV剧情运行层待迁移”，不会假装正文已运行。
- Voice：四列、每页 12 个收藏卡；默认为空，由未来 ADV 通过 `VoiceCollectionService.add_favorite()` 添加，收藏独立持久化、去重、播放、删除，并可发出存档跳转 seam。

Continue/Load 也发出统一的 `ScenarioLaunchRequest`。当前正文 ADV runner 尚未迁移，因此会进入明确的不可用提示视图；New Game 仍只保留信号 seam，未启动正文。

视频阶段按键盘、主鼠标键、手柄确认键或触摸可进入警告页。警告页第一次输入会完成淡入并将剩余等待缩短为 4 秒，第二次输入会直接开始白场过渡。Title 菜单使用语义化 `vn_advance`/`vn_cancel`/`vn_confirm`，保留 Godot 原生触摸转鼠标让所有 `Control` 走同一 GUI 路径，并由 `StartupInput` 过滤 `DEVICE_ID_EMULATION` 合成鼠标，避免一次触摸推进两次；滚轮和次鼠标键不会误触发。菜单按钮保留双帧高亮、按下/回弹反馈、手柄焦点和扩大后的触摸命中区。

环境设定现在完整复刻源 `ConfigWindowHD2` 的 HD 信息架构：

- 全屏 1920×1080 配置窗口，覆盖 Title 功能 chrome；`settings/bg.png` 拉伸为窗口边框，右上三个图像页签（Screen/System/Audio）使用真实 `graphics1/2`、`systems1/2`、`audio1/2` 双态贴图。
- Screen 页作为高 DPI 重构模板：包含全屏/窗口、1080p/900p/720p、透明度滑块、六个字体选项、简体/日语选项（日语按源工程禁用）和带头像的预览文本框。场景、`textbox.png` 对话框与 `avatar.png` 头像保留原美术素材；面板、标题、文字光带选项、开关与滑杆由 Godot 主题和 CanvasItem 绘制，不再整页渲染 `graphic/bg.png` 中烘焙的 UI chrome；已读文字颜色与头像可见性随设置实时刷新。
- System 页：五组 YES/NO 图像开关、文字速度/自动播放等待滑块、11 个确认窗口勾选框（checkbox.png 开/关帧）。
- Audio 页：九个角色语音按钮（sora/nao/akira/kazuha/motoka/ryohei/yahiro/kozue/npc 源坐标）与立绘切换；每角色独立音量使用源梯形滑块（旋钮随值 115%→155% 缩放）；六个固定 100% 全局通道滑块；角色音量拖动结束后播放源 `個別音声` 样本，音量 = Master × Voice × 角色细节（经由 Godot 总线等效实现）。
- 页脚：初始化设定/初始化已读/快捷键/返回标题四个 Godot 文本按钮；快捷键和确认弹窗共用 `SettingsModal` 的局部背景模糊、遮罩淡入淡出和居中缩放动画，只有弹窗实际覆盖区域会模糊，外侧画面保持清晰；内容仍由面板、文字和表格控件组成，不依赖文字贴图；右击或 Esc 先播放弹窗退出动画，再关闭窗口。
- 初始化流程按源 `CallConfirm`：确认窗口使用源 `ui_1920/confirm` 的 bg/yes/no/ask_always 贴图，Y/Enter 确认、N/Esc/右击取消，“总是询问”勾选框直接改写对应 `confirmations` 项；关闭勾选后重置不再弹窗。初始化设定保留窗口模式与窗口宽度（对应源保留 `fullScreen`/`windowZoom`）；初始化已读发出 typed seam（读档数据存储待 ADV 层迁移）。
- 设置模型 schema 升级到 3：语音细节从原型 9 槽迁移为源 VCID_TO_INDEX 的 11 槽（SR/AK/NO/KA/MT/RH/YH/KO/YM/SH/NP）并自动重排旧值；`window_opacity` 迁移为源的 `window_depth`（0–100）；`message_speed` 迁移为源 0–100 刻度。滑块拖动实时预览、拖动结束或 250ms debounce 后写入，且每次预览不重读磁盘。

## 运行

使用 Godot 4.7.1 或兼容的 4.7 维护版本打开目录，或执行：

```bash
godot --path .
```

项目以 1920×1080 为设计分辨率，当前开发窗口默认以 2560×1440 启动，并按 16:9 等比缩放；Title 背景独立按比例 cover 整个 viewport，内容根节点会在超宽、4:3 和竖屏窗口中保持比例，桌面端 16:9 不额外缩小，移动端再按系统安全区（不可用时使用保守 fallback）留边。

## 验证

```bash
GODOT_EXECUTABLE=/path/to/godot ./tools/verify_project.sh
```

验证脚本先检查 InputMap、存档契约、四套导出预设和关键资源；若找到 Godot，再完成资源导入、GDScript 解析并执行无头烟雾测试与迁移契约测试。

需要生成视觉回归基线时，可用 GUI 模式运行 `tests/visual_capture.gd`：

```bash
godot --path . --script res://tests/visual_capture.gd -- title /tmp/title.png 1.25
# 配置页可选第四个参数：0=Screen，1=System，2=Audio
godot --path . --script res://tests/visual_capture.gd -- settings /tmp/yosuga-settings-final.png 1.0 0
godot --path . --script res://tests/visual_capture.gd -- settings /tmp/yosuga-settings-keys.png 1.0 0 key_popup
godot --path . --script res://tests/visual_capture.gd -- settings /tmp/yosuga-settings-confirm.png 1.0 0 reset_confirm
# 退出动画中间帧可用 key_popup_closing / reset_confirm_closing
```

## 结构

更完整的依赖方向、Scene/脚本职责和新功能放置规则见 [`docs/architecture.md`](docs/architecture.md)。

- `src/app/`：负责启动状态流转及路由级合成；设置作为覆盖层保留当前页面，并通过 `BackBufferCopy + SCREEN_TEXTURE` 直接实时模糊其后方画面。Title 的离场/返回动画和设置 UI 都在同一个主 Viewport 中运行。
- `src/intro/`：品牌视频和警告页，各自管理输入与时序。
- `src/title/`：Title 路由和可复用菜单组件；`title_screen.tscn` 固定持有背景、角色差分、主菜单/鉴赏菜单按钮和底部 chrome，脚本只按存档状态同步显隐、焦点、信号与过渡；读取页使用轻量通用 host，Title 只通过 `settings` 路由请求独立设置模块。
- `src/title/content/`：manifest、Album/Music/Memories/Voice 各自拥有独立 `.tscn` 页面边界；分页卡片属于运行时数据列表，全屏 Album viewer、提示层等固定结构是可复用场景。
- `src/title/title_catalog.gd`、`title_catalog_entry.gd`：鉴赏条目定义、profile 解锁状态和内容 runner 数据接口。
- `src/settings/`：独立的环境设定路由、设置编辑器、设置模型（schema 3）和显示设置服务；`SettingsPage` 只协调设置快照、预览/保存和重置规则，页签、页脚、状态与弹窗由静态 `SettingsChrome` 子场景持有。`pages/` 的 Display/System/Audio 三个页签均为独立子场景，Audio 页自己持有语音试听器，Display 页的两列 Container、九张卡片和标题由 `.tscn` 固定持有；顶部页签使用原生 `Button`、共享 `ButtonGroup` 与 `SettingsTabButton` Theme variation，`SettingsSectionTitle` 可直接在编辑器预览；`ui/` 只保留交互/自绘组件，字号、字重、颜色、描边和 StyleBox 统一来自项目 Theme 的语义化 variation。
- `src/title/voice/`：独立的用户语音收藏 Resource/service；不把收藏错误地放入 autosave。
- `src/scenario/`：Continue、剧情回想、未来语音跳转和 ADV runner 共用的 typed request；Title 专属的不可用提示留在 `src/title/components/`。
- `src/core/audio/`：启动阶段语音随机选择、BGM 播放与循环点；`default_bus_layout.tres` 声明 Master/BGM/SystemVoice/Voice/EnvSE/SE/Movie 总线。
- `src/core/input/`：语义化动作和启动阶段统一的“继续/快进”输入判定。
- `src/core/save/`：`SaveData` 场景存档、`ProfileData` 跨存档全局进度和 `SaveService`；设置持久化由 `src/settings/persistence/SettingsRepository` 独立负责，两者共享 `src/core/persistence/AtomicJsonStore` 的原子写入与可逆备份。
- `src/ui/`：无业务语义的共享 UI 基类与布局策略；当前统一承载 1920×1080 美术画布缩放和移动端安全区换算。
- `assets/manifests/title_content_manifest.json`：从源清单整理出的可审计数据契约；契约测试固定组数、卡片/差分/音乐/回忆数量及每个媒体路径。
- `assets/content/event_1920/`：源事件图资源（包含 manifest 需要的 214 个差分以及源目录中的其他同级资源）。
- `assets/content/settings/`：源 `ui_1920/settings` HD 环境设定贴图（含 graphic/system/voices 子页与 `slider_knob.png`、`key_popup.png`）。
- `assets/content/confirm/`：源 `ui_1920/confirm` 确认窗口贴图（bg/yes/no/ask_always）。
- `assets/audio/voice_samples/`：源 `data/audio_ogg` 的 11 条“個別音声：ボリューム”样本，用于角色音量试听。
- `assets/audio/bgm/`：Title/鉴赏所需 BGM OGG；manifest 播放 21 首，另保留启动页的 `BGM07_title.ogg`。
- `assets/video/`：Godot 核心可解码的 OGV；`yosugacn` 与 5 条 Staff Roll 由源 MP4 转为 1280×720/30fps Theora，播放 manifest 不引用 MP4。
- `assets/content/thumb/`：24 条回忆缩略图；`assets/` 其余为启动页、Title UI 与字体资源。
- `assets/fonts/`、`assets/themes/`：项目级 CJK 默认 Theme、配置页的语义化 Theme variation，以及按钮/标题各自的 `FontVariation` 字重资源；配置页 StyleBox 和渐变统一放在 `assets/themes/settings/`，按 footer、popup、section 等职责拆成可直接在 Inspector 编辑的外部 `.tres`，主 Theme 只负责映射。底层字体是由源项目 `Xiaolai-Regular.ttf` 生成的 standalone Godot `FontFile` derivative，并随 `Xiaolai-Regular-OFL-1.1.txt` 附带 SIL OFL 1.1 attribution/license，冷启动不依赖 `.godot` 导入缓存。
- `tests/`：无需第三方测试框架的无头烟雾测试和输入/存档/Title/导出契约测试。

大型 PNG、音频、视频和字体已为后续提交配置 Git LFS；现有 Git 历史不会被自动重写。克隆或提交资源前需安装并启用 Git LFS。

路由边界、Title 固定视觉层/菜单、复用弹窗和 Screen 页复杂的固定分栏放在 `.tscn`；规则性很强的重复内容卡片仍由数据生成，但创建后立即赋予稳定业务名称。脚本负责依赖注入、信号和状态同步；服务只在需要它的路由中懒创建。运行时刷新列表会先从父节点移除旧项再释放，避免同帧创建同名节点后出现 `@Node@...` 自动名称。Remote 场景树因此应只显示有业务含义的节点名。

## 多平台导出

`export_presets.cfg` 已包含 Windows Desktop、macOS、Android、iOS 四个预设，Apple/Android bundle id 统一为 `com.lightwinder.yosuganosora.hdremake`。Android/iOS 预设带有 `mobile` feature，Title 会隐藏“结束游戏”；桌面平台保留退出确认。预设不写入任何签名证书、密码或 provisioning profile，正式发布时请在本机/CI 的 Godot 导出设置中注入签名资料。iOS 导出仍需 macOS + Xcode，Android 需要 Godot 对应的 SDK/JDK 工具链。

存档永远写 `user://`，不写入只读的 `res://`；`SaveData` 保留 schema/content 版本、场景锚点、局部 flag、已读文本和演出快照，`ProfileData` 单独保存跨存档全局 flag 与鉴赏解锁。每次覆盖先保留 `.bak`，可通过 `SaveService.restore_*_backup()` 恢复上一份有效文件。

`BGM07_title.ogg` 按原 `BGM07.ogg.sli` 的跳转点裁切，并从 161922 / 44100 秒处循环；`sphere.ogv` 是源 `sphere.mp4` 的 Ogg Theora 版本，以使用 Godot 核心原生视频解码器。游戏素材沿用源项目权利状态，本项目不对其重新授权。
