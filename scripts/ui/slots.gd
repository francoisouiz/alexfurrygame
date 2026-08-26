extends PanelContainer

@export var is_locked: bool = false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if is_locked:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if Variables.selected_sidebar_button != null:
			Variables.selected_slot = self
			Variables.try_click_placement()
			return
			
		if Variables.selected_slot != null and Variables.selected_slot != self:
			Variables.try_slot_to_slot_transfer(self)
			return
			
		if Variables.selected_slot != null:
			Variables.selected_slot.set_highlight(false)
			
		Variables.selected_slot = self
		set_highlight(true)
		
func set_highlight(active: bool) -> void:
	modulate = Color.DARK_ORANGE if active else Color.WHITE
	
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if is_locked:
		return false
	return data is Dictionary and data.has("button")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var dragged_button: Button = data["button"]
	var origin_slot: Control = data["origin_slot"]
	
	if origin_slot == self:
		return
		
	var from_sidebar: bool = origin_slot is GridContainer or origin_slot is BoxContainer or origin_slot.name.contains("SideBar")
	
	var target_button: Button = _get_slot_button(self)
	
	if from_sidebar:
		if target_button != null:
			remove_child(target_button)
			target_button.queue_free()
			
		var new_button: Button = dragged_button.duplicate()
		if "type" in dragged_button:
			new_button.type = dragged_button.type
		new_button.text = dragged_button.text
		
		add_child(new_button)
		_fit(new_button)
	else:
		dragged_button.get_parent().remove_child(dragged_button)
		
		if target_button != null:
			remove_child(target_button)
			origin_slot.add_child(target_button)
			_fit(target_button)
			
		add_child(dragged_button)
		_fit(dragged_button)
	Variables._clear_click_selection()
	var journal: Node = get_tree().get_first_node_in_group("journal")
	if journal and journal.has_method("check_and_trigger_pair_cutscene"):
		journal.check_and_trigger_pair_cutscene()
		
func _get_slot_button(slot: PanelContainer) -> Button:
	for child: Node in slot.get_children():
		if child is Button:
			return child
	return null
	
func _fit(button: Button) -> void:
	button.custom_minimum_size = Vector2.ZERO
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
