extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2.0)
	
	DialogueManager.show_dialogue_balloon("uid://h4l1qwlxcu25")
