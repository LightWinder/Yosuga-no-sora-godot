# 剧本多语言方案（待实现）

状态：设计已确认，待日文语料到位后实施。UI 文本多语言另行讨论，不在本文范围内。

## 目标

* 设置中提供 中文 / 日本語 切换，剧本文本随语言切换。
* 存档、已读状态、回想在两种语言下互通；切换语言不破坏任何进度数据。

## 方案：平行剧本目录

* `assets/scenario/` 保持中文基准语料（唯一控制流来源）。
* 新增 `assets/scenario_ja/`，存放日文完整语料：文件名与中文版一致（`00_a001.ks` 等），并包含自己的 `macro.ks`——`KrkrScenarioRuntime.configure()` 会从目录内重建宏定义，缺 `macro.ks` 会导致剧本无法执行。
* 切换语言即切换运行时目录：`KrkrScenarioRuntime.configure(directory)` 已存在，无需新抽象。
* 角色名、选项文本、hint 全部随语料自带，不需要额外的名字映射或翻译键。

## 硬约束：结构零差距

措辞层面的差异完全无害，但以下结构必须与中文版完全一致，否则存档与进度系统会出错：

| 结构 | 依赖方 | 不一致的后果 |
| --- | --- | --- |
| `@Hitret id` 序列 | 存档锚点 `hitret:ID`（`src/scenario/krkr_scenario_runtime.gd`）、已读键 `scenario_id:hitret_id` | 对应位置读档失败、已读状态作废 |
| `@AddSelect` 数量与顺序 | 选项历史按序重放（`_replay_saved_choice`） | 读档后选错分支或报错 |
| label 集合 | `@Change`、`AddSelect target/label` 跳转 | 剧情跳转断裂 |
| 文件集合 | 场景目录 `_rebuild_scenario_catalog()`、共用线路跳转（`_resolve_common_route_target`） | 找不到剧本 |

## 导入管线

* `tools/import_krkr_scenarios.sh` 扩展：接受第二个源目录（日文原版 KiriKiri 数据），输出到 `assets/scenario_ja/`；原版脚本可能为 Shift-JIS 编码，需在现有 UTF-16 分支外增加编码探测。
* 新增结构对齐校验（扩展 `tools/validate_utf8_scenarios.sh` 或独立脚本），逐文件比对两个目录的：文件名集合、`@Hitret id` 序列、label 集合、`@AddSelect` 数量。校验纳入导入流程，把语料跑偏从运行期错误提前到导入期报错。

## 设置与接线

* `SettingsModel` 新增 `language` 键（`"zh"` / `"ja"`，默认 `"zh"`），`normalize()` 做白名单钳制；旧档缺键自动落默认值，无需 schema 升版。
* `AdvScreen` 在 `_apply_runtime_settings()` 中根据语言调用 `_runtime.configure(...)`。该方法在 `_ready()` 中先于 `_start_request()` 执行，时序天然正确。
* ADV 内中途切换语言的语义（实现时二选一）：
  1. 重配后以当前状态重启剧本：`_runtime.start_scenario(当前ID, 当前锚点, _runtime.build_save_data())`，复用与读档相同的已验证路径；
  2. v1 先定义为"下次进入 ADV 生效"，实现最简单。
* 其他进入剧本的入口（回想等）都经由 `ScenarioLaunchRequest` 进入 ADV，配置点单一。

## 备选方案（已评估，未采纳）

单一中文基准 + 以 `scenario_id:hitret_id` 为键的日文覆盖层：控制流单源、缺失条目可回落，但需要离线对齐工具和运行时注入点，落地成本更高。若日文语料无法满足结构零差距约束，再评估此方案。

## 开放问题

* 日文原版 `.ks` 语料来源：原版游戏 KiriKiri 数据（预计 Shift-JIS）。
* 字形风格：小赖字体已实测覆盖假名与常用日文汉字（緒/葉/尋/長/声/後/対 均命中），但字形为中文书写风格；是否追加日文字体作为后续 polish，待实机观感决定。

## 验收标准

* 结构校验脚本对全部 306 对文件通过。
* 中文模式行为与现状一致；日文模式下新游戏、读档、回想、选项、快进正常。
* 同一存档在两种语言下均可读取，已读标记互通。
* 设置页语言切换后按既定语义生效，无崩溃、无剧本错误提示。
