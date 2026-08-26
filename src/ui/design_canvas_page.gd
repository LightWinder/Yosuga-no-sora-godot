class_name DesignCanvasPage
extends Control


## Shared 1920×1080 presentation surface for artwork-driven UI pages.
##
## The data/page controllers remain ordinary Controls; only their visual
## children are placed below `visual_canvas()`.  This keeps source artwork in
## design coordinates while the canvas handles desktop/mobile safe-area
## fitting in one place.
const DESIGN_SIZE := Vector2(1920.0, 1080.0)
const MOBILE_SAFE_FALLBACK := 24.0

var _visual_canvas: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_visual_canvas = get_node_or_null("VisualCanvas") as Control
	if _visual_canvas == null:
		_visual_canvas = Control.new()
		_visual_canvas.name = "VisualCanvas"
		_visual_canvas.position = Vector2.ZERO
		_visual_canvas.size = DESIGN_SIZE
		_visual_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
		add_child(_visual_canvas)
	resized.connect(_apply_visual_transform)
	_apply_visual_transform()


func visual_canvas() -> Control:
	return _visual_canvas


## Creates only genuinely data-driven artwork such as an empty-state preview.
## Stable page chrome belongs in the concrete page scene.
func add_design_texture(
		parent: Node,
		texture_path: String,
		rect: Rect2,
		stretch_mode: TextureRect.StretchMode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
) -> TextureRect:
	var texture := TextureRect.new()
	texture.name = "%sTexture%02d" % [texture_path.get_file().get_basename().to_pascal_case(), parent.get_child_count()]
	texture.texture = load(texture_path) as Texture2D
	texture.position = rect.position
	texture.size = rect.size
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = stretch_mode
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(texture)
	return texture


func _apply_visual_transform() -> void:
	DesignViewportLayout.apply(_visual_canvas, size, DESIGN_SIZE, MOBILE_SAFE_FALLBACK)
