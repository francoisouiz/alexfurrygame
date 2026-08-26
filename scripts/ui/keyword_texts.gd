extends Button

var type: String

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_PASS

func _get_drag_data(_at_position: Vector2) -> Variant:
	if mouse_filter == Control.MOUSE_FILTER_IGNORE:
		return null
	
	var origin_slot: Node = get_parent()
	if origin_slot and "is_locked" in origin_slot and origin_slot.is_locked:
		return null
		
	var drag_data: Dictionary = {
		"button": self,
		"origin_slot": get_parent()
	}
	
	var preview: Button = Button.new()
	preview.text = self.text
	preview.icon = self.icon
	preview.size = self.size
	preview.modulate.a = 0.8
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var overlay: Control = Variables.preview_layer
	overlay.add_child(preview)
	preview.global_position = _get_mouse_position_in_root() - preview.size / 2

	_active_preview = preview

	set_drag_preview(Control.new())
	
	return drag_data
	
var _active_preview: Control = null

func _pressed() -> void:
	if mouse_filter == Control.MOUSE_FILTER_IGNORE:
		return
		
	var parent_node: Node = get_parent()
	
	if parent_node is PanelContainer:
		if "is_locked" in parent_node and parent_node.is_locked:
			return
			
		if Variables.selected_sidebar_button != null:
			Variables.selected_slot = parent_node
			Variables.try_click_placement()
			return
			
		if Variables.selected_slot != null and Variables.selected_slot != parent_node:
			Variables.try_slot_to_slot_transfer(parent_node)
			return
			
		if Variables.selected_slot != null:
			Variables.selected_slot.set_highlight(false)
			
		Variables.selected_slot = parent_node
		parent_node.set_highlight(true)
		return
		
	Variables.select_sidebar_button(self)
	
func _process(_delta: float) -> void:
	if _active_preview and is_instance_valid(_active_preview):
		if not (Input.get_mouse_button_mask() & MOUSE_BUTTON_MASK_LEFT):
			_active_preview.queue_free()
			_active_preview = null
		else:
			_active_preview.global_position = _get_mouse_position_in_root() - _active_preview.size / 2

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if _active_preview and is_instance_valid(_active_preview):
			_active_preview.queue_free()
		_active_preview = null

func _get_mouse_position_in_root() -> Vector2:
	return get_tree().root.get_mouse_position()
