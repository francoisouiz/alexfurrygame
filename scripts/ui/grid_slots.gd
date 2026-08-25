extends GridContainer

@export var type: String
@export var name_container: GridContainer
@export var noun_container: GridContainer
@export var verb_container: GridContainer

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Dictionary and data.has("button")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var dragged_button: Button = data["button"]
	var origin_slot: Control = data["origin_slot"]

	if origin_slot == self:
		return
	
	origin_slot.remove_child(dragged_button)
	
	match dragged_button.type:
		"name":
			name_container.add_child(dragged_button)
		"noun":
			noun_container.add_child(dragged_button)
		"verb":
			verb_container.add_child(dragged_button)

	
	
	_reset(dragged_button)

func _reset(button: Button) -> void:
	button.custom_minimum_size = Vector2.ZERO
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
