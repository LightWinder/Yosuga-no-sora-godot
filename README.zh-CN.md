# 缘之空 · Godot HD 重制项目

[English](README.md) | **简体中文**

一个基于《缘之空》HD 素材与剧本数据进行重建的非官方 Godot 项目。

项目正在使用 **Godot 4.7** 重新实现原作的启动流程、Title / Bonus 页面、ADV 运行时、存读档系统与设置界面。运行时代码使用 typed GDScript，并尽量复用 Godot 原生的 Scene、Control、Resource、Theme 与 Shader 系统。

原 `yosuga-no-sora-remake` 工程仅作为素材与行为参考，实际运行时代码全部位于本 Godot 仓库中。

## 当前进度

目前项目已经包含：

* 启动影片、内容提示与 Title 流程
* New Game、Continue、Load 与返回标题页的路由
* 支持对话、选项、变量、条件、等待、影片、音频、履历、Auto 与 Skip 的 ADV 运行时
* 覆盖全部 306 个源 `.ks` 剧本的导入流程
* 900 个普通存档位、9 个快速存档以及独立自动存档
* 存档缩略图、复制、移动、删除、锁定、备注与确认流程
* Display、System、Audio 三类设置
* Display 页面中的轻量 ADV 实时预览
* Album、Music、Memories、Voice 四类 Bonus 鉴赏内容
* 鉴赏进度与语音收藏持久化
* 键盘、鼠标、触摸与手柄输入
* Windows、macOS、Android 与 iOS 导出目标

项目仍处于持续开发阶段，目前不应视为原作运行时的完整替代品。

## 技术特点

* **Godot 4.7 / typed GDScript** —— 不依赖 C#
* **Scene 驱动的原生 UI** —— 固定界面结构主要保存在 `.tscn` 中，而不是由脚本重新生成
* **Theme 驱动样式** —— 字体、颜色、面板及控件状态尽量通过 Godot Theme 资源复用
* **KRKR 导入边界** —— 源剧本在进入运行时之前统一转换为规范化 UTF-8
* **跨功能中立路由** —— Title、ADV、Save/Load、回想等功能通过中立契约交互
* **原子化持久化** —— 存档、设置、全局进度与语音收藏拥有明确的数据所有者及恢复机制
* **统一 1920×1080 设计空间** —— 桌面缩放与移动端安全区使用共享布局基础设施
* **Git LFS 资源管理** —— 大型图片、音频、视频和字体由 Git LFS 管理

## 环境要求

* Godot 4.7.1 或兼容的 Godot 4.7 maintenance release
* Git
* Git LFS

项目当前使用 Godot Mobile renderer，并配置 Windows、macOS、Android 与 iOS 导出目标。

## 运行项目

首次在电脑上使用 Git LFS 时执行：

```bash
git lfs install
```

克隆项目：

```bash
git clone https://github.com/LightWinder/Yosuga-no-sora-godot.git
cd Yosuga-no-sora-godot
```

如果仓库是在安装 Git LFS 之前克隆的，可以补充执行：

```bash
git lfs pull
```

随后使用 Godot 4.7.x 打开项目，或执行：

```bash
godot --path .
```

项目设计分辨率为 1920×1080，运行帧率上限为 60 FPS。

## 开发与验证

完成具有实质影响的实现修改后，建议运行：

```bash
./tools/verify_project.sh
git diff --check
```

如果 `godot` 不在 `PATH` 中，可以显式指定：

```bash
GODOT_EXECUTABLE=/path/to/godot ./tools/verify_project.sh
```

macOS 例如：

```bash
GODOT_EXECUTABLE=/Applications/Godot.app/Contents/MacOS/Godot ./tools/verify_project.sh
```

验证脚本会检查项目结构、关键资源、持久化契约、导入后的剧本数据、导出配置以及其他仓库约束。在能够找到 Godot 时，还会继续执行项目导入以及相应的脚本和运行时测试。

专项视觉截图流程位于 `tests/visual_capture.gd`。

## 项目结构

```text
src/
├── app/         应用组合、服务装配与路由
├── intro/       启动影片与内容提示流程
├── title/       Title 页面与菜单
├── appreciation/ 相册、音乐、回忆与语音鉴赏
├── adv/         ADV 表现层与媒体适配
├── save_load/   可复用的存读档功能
├── settings/    设置 UI、数据模型与持久化
├── scenario/    剧本解析/运行时及跨功能契约
├── core/        通用基础设施与持久化服务
└── ui/          可复用 UI 与设计空间布局基础设施

assets/          运行时美术、音频、视频、字体、Theme 与 manifest
tests/           运行时、契约与视觉测试
tools/           导入与验证工具
docs/            架构及专项技术文档
```

完整的依赖规则与实现边界见 [docs/architecture.md](docs/architecture.md)。

## 源工程与导入边界

运行时不直接依赖原 KRKR 工程。

源 `.ks` 剧本会通过导入工具转换为 UTF-8/LF 后再进入 `assets/scenario/`。媒体导入工具只复制运行时需要的源素材，并在必要时将源元数据转换为项目内部格式。

运行时代码应只读取项目内 Godot 资源和规范化后的数据，不应重新加入 TJS 或 UTF-16 兼容路径。

## 文档

* [项目架构](docs/architecture.md) —— 模块所有权、依赖方向、Scene 职责、持久化及功能边界
* [云层验证与调校](docs/cloud_loop_validation.md) —— Title 云层渲染及视觉验证
* [AGENTS.md](AGENTS.md) —— 提供给 coding agent 的精简仓库规则

## 当前已知限制

原作设置中使用的部分字体家族目前尚未导入 Godot。缺少对应源字体的字体选项暂时统一回退到项目内置的 Xiaolai 字体。

## 声明

本项目属于非官方的同人及技术重制项目，与原作权利方不存在官方关联或授权关系。

《缘之空》及其角色、美术、音频、视频和其他原作内容的相关权利归各自权利方所有。仓库中包含或引用的源素材不应因出现在本项目中而被视为可自由再分发的内容。
