extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	
	DialogueManager.show_dialogue_balloon(ResourceLoader.load("uid://h4l1qwlxcu25"), "start")

func knock() -> void:
	animation_player.play("knock")
	await animation_player.animation_finished
	await get_tree().create_timer(0.5).timeout

func remove_black_screen() -> void:
	animation_player.play("fadeout")
	await animation_player.animation_finished

func kill_gab() -> void:
	animation_player.play("gab_walk")
	$Gabriel.queue_free()
