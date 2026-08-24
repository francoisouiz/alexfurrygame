extends Node

@export var hover_addon: float = 20
@export var orig_custom: float
@export var pressed_scale: Vector2 = Vector2(0.9, 0.9)
@export var parent: Button

var current_tween: Tween

func _ready() -> void:
	parent.pivot_offset = parent.size / 2
	parent.mouse_entered.connect(_on_mouse_entered)
	parent.mouse_exited.connect(_on_mouse_exited)
	parent.pressed.connect(_on_pressed)

	if parent.is_active:
		parent.custom_minimum_size.y += hover_addon

func _kill_tween() -> void:
	if current_tween and current_tween.is_running():
		current_tween.kill()
	
func _on_mouse_entered() -> void:
	if not parent.is_active:
		_kill_tween()
		current_tween = create_tween()
		current_tween.tween_property(parent, "custom_minimum_size", Vector2(parent.custom_minimum_size.x, parent.custom_minimum_size.y + hover_addon), 0.1).set_trans(Tween.TRANS_SINE)
		
func _on_mouse_exited() -> void:
	if not parent.is_active:
		_kill_tween()
		current_tween = create_tween()
		current_tween.tween_property(parent, "custom_minimum_size", Vector2(parent.custom_minimum_size.x, orig_custom), 0.1).set_trans(Tween.TRANS_SINE)
	
func _on_pressed() -> void:
	_kill_tween()
	current_tween = create_tween()
	current_tween.tween_property(parent, "scale", pressed_scale, 0.06).set_trans(Tween.TRANS_SINE)
	current_tween.tween_property(parent, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_SINE)
