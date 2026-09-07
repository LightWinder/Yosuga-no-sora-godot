class_name AdvBackgroundPreview
extends SubViewport


## A request-scoped, offscreen snapshot of the background camera only. The
## cloned subtree contains the current background and any scrolling tiles;
## dialogue, system menu, characters and transitions never enter this viewport.
func capture(camera: Control, fallback: ColorRect) -> Image:
	var snapshot := camera.duplicate(0) as Control
	snapshot.name = "BackgroundSnapshot"
	(%Canvas as Control).add_child(snapshot)
	(%Fallback as ColorRect).color = fallback.color * fallback.modulate
	render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	return get_texture().get_image()
