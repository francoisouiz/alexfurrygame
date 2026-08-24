extends Button

var type: String

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS

func _get_drag_data(_at_position: Vector2) -> Variant:
	var drag_data: Dictionary = {
		"button": self,
		"origin_slot": get_parent()
	}
	var preview: Button = Button.new()
	preview.text = self.text
	preview.icon = self.icon
	preview.size = self.size
	preview.modulate.a = 0.8
	
	set_drag_preview(preview)
	return drag_data
