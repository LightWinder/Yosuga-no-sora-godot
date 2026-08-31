class_name AdvChoiceButton
extends Button


const FRAME_SIZE := Vector2(1300.0, 105.0)
const DEFAULT_TEXTURE: Texture2D = preload("res://assets/content/adv/ui/gameoption.png")
const ROUTE_TEXTURES := {
	"穹": preload("res://assets/content/adv/ui/gameoption.sora.png"),
	"奈緒": preload("res://assets/content/adv/ui/gameoption.nao.png"),
	"奈绪": preload("res://assets/content/adv/ui/gameoption.nao.png"),
	"瑛": preload("res://assets/content/adv/ui/gameoption.akira.png"),
	"一葉": preload("res://assets/content/adv/ui/gameoption.kuzuha.png"),
	"一叶": preload("res://assets/content/adv/ui/gameoption.kuzuha.png"),
	"初佳": preload("res://assets/content/adv/ui/gameoption.motoka.png"),
}

@onready var _background: TextureRect = %Background
@onready var _label: Label = %ChoiceText

var choice_index := -1
var choice_text := ""
var _source_texture: Texture2D = DEFAULT_TEXTURE


func _ready() -> void:
	mouse_entered.connect(_refresh_frame)
	mouse_exited.connect(_refresh_frame)
	focus_entered.connect(_refresh_frame)
	focus_exited.connect(_refresh_frame)
	button_down.connect(_refresh_frame)
	button_up.connect(_refresh_frame)
	_refresh_frame()


func configure(index: int, display_text: String, route_hint: String, route_guide_enabled: bool) -> void:
	choice_index = index
	choice_text = display_text
	_label.text = display_text
	_source_texture = _route_texture(route_hint) if route_guide_enabled else DEFAULT_TEXTURE
	_refresh_frame()


func set_choice_disabled(value: bool) -> void:
	disabled = value
	_label.modulate.a = 0.48 if value else 1.0
	_refresh_frame()


func _route_texture(route_hint: String) -> Texture2D:
	if route_hint.contains("/") or route_hint.contains(","):
		return DEFAULT_TEXTURE
	return ROUTE_TEXTURES.get(route_hint.strip_edges(), DEFAULT_TEXTURE) as Texture2D


func _refresh_frame() -> void:
	if not is_node_ready() or _background == null:
		return
	var highlighted := not disabled and (is_hovered() or has_focus() or is_pressed())
	var atlas := AtlasTexture.new()
	atlas.atlas = _source_texture
	atlas.region = Rect2(FRAME_SIZE.x if highlighted else 0.0, 0.0, FRAME_SIZE.x, FRAME_SIZE.y)
	_background.texture = atlas
