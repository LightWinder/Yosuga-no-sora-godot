# 整图动态云：实现与验证

## 当前状态

Title 已使用 `AAA.png` 和单个全屏 ColorRect 的放射 Shader。云沿半径向设计坐标 (1280, 864) 收束，外围大、中心小。用户明确允许先推进实现、素材接缝后修，因此接缝问题不再作为第二阶段的阻塞条件；这版不宣称素材已完全无缝。

`assets/ui/title/clouds/AAA.png` 是用户提供的 1920×1600 RGBA 原文件副本，未修图或重绘。旧 `cloud_loop_test.png` 保留作对照。Title 的背景、云层和 UI 分别绘制；天空遮罩防止云覆盖山树草地。

## 运行与调参

直接运行 Title；独立观察云使用 `tests/cloud_radial_test.tscn`。普通垂直循环测试 `tests/cloud_test.tscn` 也已切换到 AAA，可继续检查源图上下接合处。

Title 的参数集中在 `assets/shaders/title/title_perspective_clouds_material.tres`，可通过 Inspector 调整：

| 参数 | 当前值 | 用途 |
| --- | --- | --- |
| focus_uv | (0.6666667, 0.8) | 消失点，随背景 cover 裁切保持对齐 |
| speed | 0.015 | 每秒移动的纹理周期；正值向中心，负值反向 |
| radial_scale | 20.0 | 径向 log 曲线 |
| radial_repeat | 0.45 | 径向密度，与 radial_scale 配合调形状 |
| angular_repeat | 2.0 | 上半幅 180° 展开一整张云纹理 |
| center_fade_start / end | 0.06 / 0.18 | 中心静态空间淡出，减少云尖聚集 |
| opacity | 1.0 | 云整体透明度 |
| phase | 0.15 | 初始构图相位 |
| uv_offset | (-0.5, 0) | 纹理布局偏移 |
| uv_scale | (1, 1) | 纹理重复密度 |
| use_sky_mask | true | 启用山树遮挡 |
| artwork_aspect | 1.7768332 | 当前背景 1672/941 的原始比例 |

原始提案中的低径向尺度在当前贴图上会产生很宽的云体和中心细针；当前组合经过实际渲染调节。仍使用 angle → U、log(1 + r × radial_scale) → V，没有引入分层、单云实例、重生、旋转或呼吸缩放。

Shader 在背景原画坐标中计算透视，并修正横纵比。角度分支切口放在消失点下方。采样器开启 repeat 和 mipmaps，交由纹理采样处理循环，不在采样前手动 fract 导致 mip 导数突变。

`src/title/title_cloud_field.gd` 读取材质的 speed 与 uv_scale.y，使用每个场景实例独立的双精度相位钟，并把相位限制在一个周期内；Shader 不依赖引擎 TIME 的整点回绕。最终采样 V 加上这个相位，所以非整数密度也不会在时钟回绕时整体跳变。默认周期约 66.67 秒。隐藏云层或暂停场景树时停止推进；speed=0 冻结当前位置。

普通循环材质默认 uv_scale=(1, 0.675)，按 1080/1600 保持原图像素比例；它只用于素材检查，不加天空遮罩。

## 遮罩与导入设置

`assets/ui/title/clouds/sky_mask.svg` 根据当前无云背景的天空边界生成，可用 `tools/assets/build_title_sky_mask.py` 重建。它是近似的轮廓遮罩，细小树叶空隙还可后续精修；更换无云背景时应重新生成并检查对齐。

AAA 使用无损导入、Alpha 边缘修正、非预乘 Alpha、mipmaps。仓库仅为 `AAA.png.import` 增加忽略规则例外，以保留其导入设置；不提交 `.godot` 缓存。源 PNG 中隐藏 RGB 的蓝色块不能直接当作可见残留，应结合 Alpha 合成判断。

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

放射截图文件名中的 phase 是运行时滚动相位，不包含材质的初始 phase=0.15。SubViewport 尺寸检查独立于桌面窗口尺寸限制，覆盖 1440×1080、2560×1080、720×1280。

## 2026-09-07 验证结果与限制

- Godot 4.7.2 / OpenGL Compatibility：实际 Title 连续运行 70 秒、7983 帧，超过一个默认周期。检查了运行截图及不同宽高比下的背景、云和遮罩对齐。
- GPU 截图 phase 0 与 1 最大通道差为 0；phase 0.002 与 1.002 也完全一致。这证明相位周期一致，不代表源图上下边界连续。
- 相邻相位 0 → 0.002 的局部图像匹配：左侧云约 (+3,+3) px、中央 (0,+3) px、右侧 (-2,+2) px，符合要求的三个方向。
- 左下前景区域 x=0..799、y=950..1049 与无云截图最大通道差为 0。
- `tests/title_cloud_field_test.gd` 验证参数、独立材质、周期回绕、变速、反向、隐藏暂停，以及非默认速度/密度跨越一小时；已纳入项目 verifier。
- AAA 顶行 Alpha 最高 192/255，底行完全透明，左右边缘也有最高 18/255 的非透明像素。局部云尖仍会在纹理边界截断；需要后续在素材制作文件中修复 RGB 与 Alpha 的连续性。
- 当前纹理纵向云密度不均，因此播放中天空会经历较密和较疏的构图；中心附近仍有细长云尖，后续可随素材修复继续调整密度和曲线。
- 已有源 OGG 元数据、UID 路径回退及本机编辑器设置/证书警告不属于本次云层故障；以 verifier 退出状态和 fatal 检查为准。
