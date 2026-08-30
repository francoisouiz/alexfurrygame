extends Button

@export var background_sprite: AnimatedSprite2D
@export var toggle_animation_name: StringName = &"default"

var is_toggled: bool = false
var is_hovered: bool = false

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	pressed.connect(_on_pressed)
	
	if is_instance_valid(background_sprite):
		background_sprite.frame_changed.connect(_on_sprite_frame_changed)

func _on_mouse_entered() -> void:
	is_hovered = true
	if not is_toggled and is_instance_valid(background_sprite):
		background_sprite.play(toggle_animation_name)

func _on_mouse_exited() -> void:
	is_hovered = false
	if not is_toggled and is_instance_valid(background_sprite):
		background_sprite.play_backwards(toggle_animation_name)

func _on_pressed() -> void:
	is_toggled = !is_toggled
	
	if not is_instance_valid(background_sprite):
		return
		
	if is_toggled:
		background_sprite.play(toggle_animation_name)
	else:
		background_sprite.play_backwards(toggle_animation_name)

func _on_sprite_frame_changed() -> void:
	if not is_instance_valid(background_sprite):
		return
		
	# Force pause at frame 0 when playing backwards
	if background_sprite.speed_scale < 0 or background_sprite.get_playing_speed() < 0:
		if background_sprite.frame == 0:
			background_sprite.pause()
