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

## 运行

使用 Godot 4.7.1 或兼容的 4.7 维护版本打开目录，或执行：

```bash
godot --path .
```

项目以 1920×1080 为设计分辨率，窗口默认以 1280×720 启动，并按 16:9 等比缩放；Title 背景独立按比例 cover 整个 viewport，内容根节点会在超宽、4:3 和竖屏窗口中保持比例，桌面端 16:9 不额外缩小，移动端再按系统安全区（不可用时使用保守 fallback）留边。

## 验证

```bash
GODOT_EXECUTABLE=/path/to/godot ./tools/verify_project.sh
```

验证脚本先检查 InputMap、存档契约、四套导出预设和关键资源；若找到 Godot，再完成资源导入、GDScript 解析并执行无头烟雾测试与迁移契约测试。

需要生成视觉回归基线时，可用 GUI 模式运行 `tests/visual_capture.gd`：

```bash
godot --path . --script res://tests/visual_capture.gd -- title /tmp/title.png 1.25
```

## 结构

- `src/app/`：只负责启动状态流转，不包含页面实现细节。
- `src/intro/`：品牌视频和警告页，各自管理输入与时序。
- `src/title/`：Title 路由、可复用菜单按钮、Load/Config/Bonus 页面。
- `src/title/content/`：manifest、Album/Music/Memories/Voice 独立页面、分页网格、Album viewer 与媒体请求。
- `src/title/title_catalog.gd`、`title_catalog_entry.gd`：鉴赏条目定义、profile 解锁状态和内容 runner 数据接口。
- `src/title/config/`：完整 Audio/Screen/System 设置模型与 debounce 提交。
- `src/title/voice/`：独立的用户语音收藏 Resource/service；不把收藏错误地放入 autosave。
- `src/title/scenario/`：Continue、剧情回想和未来语音跳转共用的 typed request 与不可用提示。
- `src/core/audio/`：启动阶段语音随机选择、BGM 播放与循环点；`default_bus_layout.tres` 声明 Master/BGM/SystemVoice/Voice/EnvSE/SE/Movie 总线。
- `src/core/input/`：语义化动作和启动阶段统一的“继续/快进”输入判定。
- `src/core/save/`：`SaveData` 场景存档、`ProfileData` 跨存档全局进度和 `SaveService`；使用 `user://`、临时文件、跨平台 backup/restore 替换、错误保留和迁移别名。
- `assets/manifests/title_content_manifest.json`：从源清单整理出的可审计数据契约；契约测试固定组数、卡片/差分/音乐/回忆数量及每个媒体路径。
- `assets/content/event_1920/`：源事件图资源（包含 manifest 需要的 214 个差分以及源目录中的其他同级资源）。
- `assets/audio/bgm/`：Title/鉴赏所需 BGM OGG；manifest 播放 21 首，另保留启动页的 `BGM07_title.ogg`。
- `assets/video/`：Godot 核心可解码的 OGV；`yosugacn` 与 5 条 Staff Roll 由源 MP4 转为 1280×720/30fps Theora，播放 manifest 不引用 MP4。
- `assets/content/thumb/`：24 条回忆缩略图；`assets/` 其余为启动页、Title UI 与字体资源。
- `assets/fonts/`、`assets/themes/`：项目级 CJK 默认 Theme 与由源项目 `Xiaolai-Regular.ttf` 生成的 standalone Godot `FontFile` derivative；字体随 `Xiaolai-Regular-OFL-1.1.txt` 附带 SIL OFL 1.1 attribution/license，冷启动不依赖 `.godot` 导入缓存。
- `tests/`：无需第三方测试框架的无头烟雾测试和输入/存档/Title/导出契约测试。

## 多平台导出

`export_presets.cfg` 已包含 Windows Desktop、macOS、Android、iOS 四个预设，Apple/Android bundle id 统一为 `com.lightwinder.yosuganosora.hdremake`。Android/iOS 预设带有 `mobile` feature，Title 会隐藏“结束游戏”；桌面平台保留退出确认。预设不写入任何签名证书、密码或 provisioning profile，正式发布时请在本机/CI 的 Godot 导出设置中注入签名资料。iOS 导出仍需 macOS + Xcode，Android 需要 Godot 对应的 SDK/JDK 工具链。

存档永远写 `user://`，不写入只读的 `res://`；`SaveData` 保留 schema/content 版本、场景锚点、局部 flag、已读文本和演出快照，`ProfileData` 单独保存跨存档全局 flag 与鉴赏解锁。每次覆盖先保留 `.bak`，可通过 `SaveService.restore_*_backup()` 恢复上一份有效文件。

`BGM07_title.ogg` 按原 `BGM07.ogg.sli` 的跳转点裁切，并从 161922 / 44100 秒处循环；`sphere.ogv` 是源 `sphere.mp4` 的 Ogg Theora 版本，以使用 Godot 核心原生视频解码器。游戏素材沿用源项目权利状态，本项目不对其重新授权。
