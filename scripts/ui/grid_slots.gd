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

	if origin_slot is GridContainer:
		return
		
	dragged_button.queue_free()
