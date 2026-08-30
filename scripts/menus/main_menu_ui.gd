extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_start_pressed() -> void:
	SceneLoader.load_scene(Constants.SCENE_PATHS.lucius_room)
	Constants.current_level = "lucius_room"


func _on_quit_pressed() -> void:
	pass # Replace with function body.
