class_name TitleExitConfirmation
extends Control


## Reusable, scene-owned confirmation overlay for the desktop exit route.
## TitleScreen decides when it is allowed to open; this component only owns
## its visual hierarchy, focus entry point and typed result signals.
signal confirmed
signal canceled

@onready var _confirm_button: Button = $Dialog/Margin/Content/Actions/ConfirmExit
@onready var _cancel_button: Button = $Dialog/Margin/Content/Actions/CancelExit


func _ready() -> void:
	_confirm_button.pressed.connect(func() -> void: confirmed.emit())
	_cancel_button.pressed.connect(func() -> void: canceled.emit())
	visible = false


func open() -> void:
	visible = true
	_cancel_button.grab_focus()


func close() -> void:
	visible = false
