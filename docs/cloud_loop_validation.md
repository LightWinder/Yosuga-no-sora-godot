# 整图动态云：实现与验证

## 当前状态

Title 已使用 `title_cloud_radial_atlas.png` 和单个全屏 ColorRect 的放射 Shader。云只在汇聚位置上方参与映射：左侧向右下、中央向下、右侧向左下运动，进入路线末段后逐步降低透明度，最终进入山脊遮挡。汇聚位置位于设计坐标 (1280, 950.4)，肉眼不会在天空中看到点状黑洞。

`assets/ui/title/clouds/title_cloud_radial_atlas.png` 是用户提供的 1920×1600 RGBA 云图集，文件名说明其角度/半径展开用途。旧 `cloud_loop_test.png` 保留作对照。Title 的背景、云层和 UI 直接在主 Viewport 中分层绘制，并受全局 60 FPS 上限控制。天空遮罩防止云覆盖山树草地。

## 运行与调参

直接运行 Title；独立观察云使用 `tests/cloud_radial_test.tscn`。普通垂直循环测试 `tests/cloud_test.tscn` 也使用同一放射云图集，可继续检查源图上下接合处。

Title 的参数集中在 `assets/shaders/title/title_perspective_clouds_material.tres`，可通过 Inspector 调整：

| 参数 | 当前值 | 用途 |
| --- | --- | --- |
| focus_uv | (0.6666667, 0.88) | 山脊附近的汇聚位置，随背景 cover 裁切保持对齐 |
| speed | 0.004 | 每秒移动的纹理周期；正值向山后，负值反向 |
| distortion_speed | 0.008 | 云形扰动每秒推进的独立循环相位 |
| distortion_strength_px | 1.4 | 原画像素尺度的最大轻微形变 |
| distortion_scale | 3.0 | 扰动波在画面中的空间频率 |
| radial_scale | 20.0 | 径向 log 曲线 |
| radial_repeat | 0.45 | 径向密度，与 radial_scale 配合调形状 |
| angular_repeat | 2.0 | 上半幅 180° 展开一整张云纹理 |
| center_fade_start / end | 0.02 / 0.08 | 汇聚位置附近的局部淡出 |
| horizon_fade | 0.18 | 从原画 y=0.70 到 y=0.88 的末段渐隐宽度 |
| left_lift | 0.04 | 最左侧角域沿原路线向外抬高的相位偏移 |
| opacity | 1.0 | 云整体透明度 |
| phase | 0.15 | 初始构图相位 |
| uv_offset | (-0.5, 0) | 纹理布局偏移 |
| uv_scale | (1, 1) | 纹理重复密度 |
| use_sky_mask | true | 启用山树遮挡 |
| mask_overlap_px | 6.0 | 将云层可见边缘向山树内部延伸，消除轮廓空隙 |
| artwork_aspect | 1.7768332 | 当前背景 1672/941 的原始比例 |

原始提案中的低径向尺度在当前贴图上会产生很宽的云体和中心细针；当前组合经过实际渲染调节。仍使用 angle → U、log(1 + r × radial_scale) → V，没有引入分层、单云实例、重生、旋转或呼吸缩放。

Shader 在背景原画坐标中计算角度和半径，并修正横纵比。角度分支切口位于汇聚位置下方；该区域不参与显示。末段纵向渐隐和天空遮罩依次降低 Alpha，使云在接近山脊时自然消失。遮罩边缘向山树内部重叠 6 px，并收紧线性过滤产生的灰边，避免云与前景之间出现描边式空隙。采样器开启 repeat 和 mipmaps，交由纹理采样处理循环，不在采样前手动 fract，避免 mip 导数突变和矩形裁切边界。

`src/title/title_cloud_field.gd` 为主流动和形变分别维护场景实例独立的双精度相位钟，并把相位限制在一个周期内；Shader 不依赖引擎全局时间的整点回绕。主流动默认周期约 250 秒，形变周期约 125 秒。隐藏云层或暂停场景树时两者都停止推进；speed=0 只冻结路线移动，仍可保留缓慢的云形变化。

普通循环材质默认 uv_scale=(1, 0.675)，按 1080/1600 保持原图像素比例；它只用于素材检查，不加天空遮罩。

## 遮罩与导入设置

`assets/ui/title/clouds/sky_mask.svg` 根据当前无云背景的天空边界生成，可用 `tools/assets/build_title_sky_mask.py` 重建。它是近似的轮廓遮罩，细小树叶空隙还可后续精修；更换无云背景时应重新生成并检查对齐。

放射云图集使用无损导入、Alpha 边缘修正、非预乘 Alpha、mipmaps。仓库仅为 `title_cloud_radial_atlas.png.import` 增加忽略规则例外，以保留其导入设置；不提交 `.godot` 缓存。源 PNG 中隐藏 RGB 的蓝色块不能直接当作可见残留，应结合 Alpha 合成判断。

## 可复现检查

截图需要真实图形渲染，不能使用 `--headless`：

```bash
# 独立场景：确定相位和真正不同尺寸的 SubViewport 截图
/Applications/Godot.app/Contents/MacOS/Godot --audio-driver Dummy --rendering-method gl_compatibility --path . --resolution 1920x1080 --script res://tests/cloud_radial_capture.gd -- /tmp/yosuga-cloud-radial

# 实际 Title：持续播放 70 秒，每 10 秒截图
/Applications/Godot.app/Contents/MacOS/Godot --audio-driver Dummy --rendering-method gl_compatibility --path . --resolution 1920x1080 --script res://tests/cloud_radial_capture.gd -- /tmp/yosuga-cloud-title 70 title

# 原图垂直循环与接缝放大检查
/Applications/Godot.app/Contents/MacOS/Godot --audio-driver Dummy --rendering-method gl_compatibility --path . --resolution 1920x1080 --script res://tests/cloud_loop_capture.gd -- /tmp/yosuga-cloud-loop
```

截图文件名中的 phase 是运行时滚动相位，不包含材质的初始 phase=0.15。SubViewport 尺寸检查独立于桌面窗口尺寸限制，覆盖 1440×1080、2560×1080、720×1280。

## 2026-09-08 验证结果与限制

- Godot 4.7.2 / OpenGL Compatibility：实际 Title 连续运行 70 秒、7983 帧，超过一个默认周期。检查了运行截图及不同宽高比下的背景、云和遮罩对齐。
- GPU 截图 phase 0 与 1 最大通道差为 0；phase 0.002 与 1.002 也完全一致。这证明相位周期一致，不代表源图上下边界连续。
- 实际 Title 多相位截图确认左侧向右下、中央向下、右侧向左下；汇聚位置以下不参与采样，云由末段渐隐和山脊遮罩共同隐藏，没有从地面反向进入天空的路径。
- 完整角度采样使用硬件 repeat，截图中没有矩形或斜线裁切边界；左下前景由天空遮罩保护。
- `tests/title_cloud_field_test.gd` 验证参数、独立材质、周期回绕、变速、反向、隐藏暂停，以及非默认速度/密度跨越一小时；已纳入项目 verifier。
- 新图集需要继续以普通循环截图和完整周期 Title 截图检查上下边缘；实际验收以合成后的 Alpha 连续性为准。
- 当前纹理纵向云密度不均，因此播放中天空会经历较密和较疏的构图；中心附近仍有细长云尖，可继续通过素材与曲线微调。
- 已有源 OGG 元数据、UID 路径回退及本机编辑器设置/证书警告不属于本次云层故障；以 verifier 退出状态和 fatal 检查为准。
