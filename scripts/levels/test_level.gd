extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var sprite: Sprite3D = player.get_node("Sprite3D")
@onready var camera: Camera3D = sprite.get_node("Camera3D")

func _ready() -> void:
	await RenderingServer.frame_post_draw
	camera.get_texture().get_image().save_png("user://Screenshot.png")
