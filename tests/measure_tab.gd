extends SceneTree


func _init() -> void:
	var font := load("res://assets/fonts/Xiaolai-Regular.fontdata") as Font
	var size := 64
	for label in ["画面", "システム", "オーディオ", "系统", "音频"]:
		var plain := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x
		var bulleted := font.get_string_size("• %s •" % label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x
		print("%s plain=%.0f bulleted=%.0f decoration=%.0f (per side %.0f)" % [label, plain, bulleted, bulleted - plain, (bulleted - plain) / 2.0])
	# What are the components?
	print("bullet alone: %.0f" % font.get_string_size("•", HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x)
	print("space alone: %.0f" % font.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x)
	print("dot+space: %.0f" % font.get_string_size("• ", HORIZONTAL_ALIGNMENT_LEFT, -1.0, size).x)
	quit(0)
