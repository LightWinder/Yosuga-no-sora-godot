class_name ConfigSectionCard
extends PanelContainer


## Scene-owned configuration card. Page controllers attach behavior to named
## controls inside Content instead of rebuilding the card hierarchy at runtime.
func _ready() -> void:
	ConfigVisualTokens.apply_panel(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
