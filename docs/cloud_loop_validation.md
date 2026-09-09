# Title Cloud Field

Title 使用单个全屏 `TitleCloudField` 渲染动态云层。

云素材：

```text
assets/ui/title/clouds/title_cloud_radial_atlas.png
```

主要实现：

```text
src/title/title_cloud_field.gd
src/title/title_cloud_field.tscn
assets/shaders/title/title_perspective_clouds.gdshader
assets/shaders/title/title_perspective_clouds_material.tres
```

## Design

云层通过一个 CanvasItem Shader 对完整云图进行放射映射：

* 左侧云向右下运动
* 中央云向下运动
* 右侧云向左下运动
* 云在山脊附近逐渐淡出
* `sky_mask.svg` 防止云覆盖山体、树木和地面
* 动画使用 Scene 自己维护的 phase，不依赖 Godot 全局 `TIME`

Title 中不存在单独的云实例、respawn 或对象池。

## Tuning

视觉参数集中在：

```text
assets/shaders/title/title_perspective_clouds_material.tres
```

常用参数：

| 参数                               | 作用         |
| -------------------------------- | ---------- |
| `speed`                          | 云整体移动速度    |
| `distortion_speed`               | 云形缓慢变化速度   |
| `distortion_strength_px`         | 云形扰动强度     |
| `focus_uv`                       | 放射运动汇聚位置   |
| `radial_scale` / `radial_repeat` | 径向形状与密度    |
| `horizon_fade`                   | 接近山脊时的渐隐范围 |
| `mask_overlap_px`                | 云与山脊遮罩的重叠量 |

修改背景图后，需要重新检查 `focus_uv` 和 `sky_mask.svg`。

## Automated test

云层运行时 contract 由：

```text
tests/title_cloud_field_test.gd
```

验证，并由项目 verifier 执行：

```bash
./tools/verify_project.sh
```

自动测试负责检查结构、材质状态和动画 phase 等可以稳定机械判断的行为。

## Visual check

Shader 最终效果仍属于视觉内容，以下问题不适合作为严格的单元测试：

* 云图接缝是否肉眼可见
* 山脊遮罩是否自然
* 不同宽高比下构图是否好看
* 某个 phase 是否出现过密或过疏的云
* 云尖等素材本身的视觉问题

需要检查这些问题时运行：

```bash
godot --path . \
  --script res://tests/cloud_radial_capture.gd \
  -- /tmp/yosuga-cloud-radial
```

视觉检查工具属于诊断手段，不是正常 CI / verifier 的必要步骤。
