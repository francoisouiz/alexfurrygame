extends PanelContainer

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("button")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var dragged_button: Button = data["button"]
	var origin_slot: Control = data["origin_slot"]
	
	if origin_slot == self:
		return
	
	var local_button: Button = null
	for child: Variant in get_children():
		if child is Button:
			local_button = child
		
	if local_button == null:
		origin_slot.remove_child(dragged_button)
		add_child(dragged_button)
		_fit(dragged_button)
	else:
		origin_slot.remove_child(dragged_button)
		self.remove_child(local_button)
		print(local_button)
		self.add_child(dragged_button)
		
		match local_button.type:
			"name":
				Variables.keywordNames.add_child(local_button)
			"noun":
				Variables.keywordNouns.add_child(local_button)
			"verb":
				Variables.keywordVerbs.add_child(local_button)

		_fit(dragged_button)

func _fit(button: Button) -> void:
	button.custom_minimum_size = Vector2.ZERO
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
		
