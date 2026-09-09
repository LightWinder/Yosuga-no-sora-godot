class_name SettingsKeyPopup
extends ModalOverlay


## Code-rendered shortcut reference. The rows are data, while the stable
## overlay/panel hierarchy lives in settings_key_popup.tscn.
signal close_requested

const SHORTCUT_ACTIONS: Array[String] = [
	"显示/隐藏文本框",
	"快速保存",
	"快速读取",
	"设定",
	"自动模式",
	"快进模式",
	"强制快进模式",
	"文本记录",
	"语音重播",
	"跳转至前选项",
	"跳转至后选项",
]
const SHORTCUT_KEYS: Array[String] = [
	"ESC",
	"F1",
	"F2",
	"F5",
	"F6",
	"F7",
	"左 Ctrl",
	"F8",
	"F9",
	"←",
	"→",
]

@onready var _panel: PanelContainer = $Center/PopupPanel
@onready var _title: Label = $Center/PopupPanel/Margin/Content/Title
@onready var _rows: GridContainer = $Center/PopupPanel/Margin/Content/ShortcutRows
@onready var _hint: Label = $Center/PopupPanel/Margin/Content/Hint
@onready var _close_button: SettingsTextButton = $Center/PopupPanel/Margin/Content/CloseButton


func _ready() -> void:
	super._ready()
	_build_shortcut_rows()
	_shade.gui_input.connect(_on_shade_gui_input)
	_close_button.pressed.connect(func() -> void: close_requested.emit())


func open() -> void:
	show_modal()
	_close_button.grab_focus()


func close() -> void:
	hide_modal()


func is_open() -> bool:
	return is_modal_open()


func is_active() -> bool:
	return is_modal_active()


func shortcut_count() -> int:
	return SHORTCUT_ACTIONS.size()


func _build_shortcut_rows() -> void:
	assert(SHORTCUT_ACTIONS.size() == SHORTCUT_KEYS.size())
	for index in SHORTCUT_ACTIONS.size():
		_rows.add_child(_make_row_label(SHORTCUT_ACTIONS[index], false, index))
		_rows.add_child(_make_row_label(SHORTCUT_KEYS[index], true, index))


func _make_row_label(caption: String, is_key: bool, index: int) -> Label:
	var label := Label.new()
	label.name = ("Key%02d" if is_key else "Action%02d") % index
	label.text = caption
	label.custom_minimum_size = Vector2(220.0 if is_key else 430.0, 48.0)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if is_key else HORIZONTAL_ALIGNMENT_LEFT
	label.theme_type_variation = &"SettingsPopupKey" if is_key else &"SettingsPopupAction"
	return label


func _on_shade_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		close_requested.emit()
