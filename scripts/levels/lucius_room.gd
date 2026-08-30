extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gabriel: AnimatableBody3D = $Gabriel
@onready var anim: AnimatedSprite3D = $Gabriel/AnimatedSprite3D
@onready var audio_stream_player_3d_2: AudioStreamPlayer3D = $AudioStreamPlayer3D2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	anim.flip_h = true
	#DialogueManager.show_dialogue_balloon(ResourceLoader.load("uid://h4l1qwlxcu25"), "start")

func knock() -> void:
	animation_player.play("knock")
	await animation_player.animation_finished
	await get_tree().create_timer(0.5).timeout
	audio_stream_player_3d_2.play()

func remove_black_screen() -> void:
	animation_player.play("fadeout")
	await animation_player.animation_finished

func kill_gab() -> void:
	animation_player.play("gab_walk")
	$Gabriel.queue_free()
