# 项目架构

本项目按“组合根 → 功能模块 → 通用基础设施”组织。依赖只能沿下图向下，功能模块之间通过中立契约通信，不直接引用对方的页面实现。

```text
src/app/                     启动、路由、依赖装配
    ├── src/intro/           启动画面
    ├── src/title/           标题页与鉴赏功能
    ├── src/settings/        设置功能与 SettingsRepository
    └── src/scenario/        ADV 启动请求等跨功能契约
             │
             ▼
src/core/                    存档、音频、输入、原子持久化
src/ui/                      不含业务语义的共享 UI/layout
```

## 依赖规则

1. `src/app/` 是组合根：创建服务、连接跨模块信号、决定页面路由。
2. `src/core/` 不得导入 `title`、`settings` 等功能目录。
3. 跨功能数据放在中立目录。例如 Title 只发出 `ScenarioLaunchRequest`，不拥有未来的 ADV runner。
4. 功能专属弹窗、控件和服务留在功能目录；只有具备两个以上真实调用方且不含业务语义时，才提升到 `src/ui/` 或 `src/core/`。
5. 持久化按数据生命周期拆分：`SaveService` 只负责存档/profile，`SettingsRepository` 只负责设置，语音收藏独立于 autosave；三者共享 `AtomicJsonStore`。

## Scene 与脚本的职责

- 固定节点、布局、层级、主题 variation 和可复用弹窗由 `.tscn` 持有，可在编辑器和 Remote Tree 中直接检查。
- 脚本负责依赖注入、信号、状态同步、分页和数据驱动的重复项。
- 运行时只生成数量取决于 manifest 或用户数据的节点，例如相册卡片、曲目、回忆与收藏项。
- 动态项必须使用稳定业务名称；刷新列表时先从父节点移除旧项，再 `queue_free()`，避免同帧重名。
- 1920×1080 美术坐标页统一复用 `DesignCanvasPage` / `DesignViewportLayout`，不要在页面中复制缩放与安全区算法。

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

脚本会先检查目录边界、场景所有权、内容 manifest 和关键资源。如果能找到 Godot，还会继续执行编辑器导入及无头烟雾/契约测试；否则会明确报告只完成了静态检查。
