extends Node

@export var overlay_rect: ColorRect
@export var tutorial_label: Label

var shader_material: ShaderMaterial
var tween: Tween

func _ready() -> void:
	if is_instance_valid(overlay_rect):
		overlay_rect.hide()
	if is_instance_valid(tutorial_label):
		tutorial_label.hide()
	
	var _unused: bool = _initialize_overlay()

func _initialize_overlay() -> bool:
	if is_instance_valid(overlay_rect):
		if overlay_rect.material is ShaderMaterial:
			shader_material = overlay_rect.material as ShaderMaterial
			return true
	return false

func start_spotlight_sequence(targets: Array[Control], text_messages: Array[String], padding: float = 20.0) -> void:
	if not is_instance_valid(overlay_rect) or shader_material == null:
		if not _initialize_overlay():
			return

	if targets.is_empty():
		return
		
	var first_uv: Vector2 = _get_control_screen_uv(targets[0])
	var first_size: Vector2 = _get_control_hole_size(targets[0], padding)
	
	shader_material.set_shader_parameter("center_position", first_uv)
	shader_material.set_shader_parameter("hole_size", Vector2(1.0, 1.0))
	
	overlay_rect.show()
	
	if is_instance_valid(tutorial_label):
		tutorial_label.hide()
		tutorial_label.z_index = 100
	
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(shader_material, "shader_parameter/hole_size", first_size, 0.8)
	await tween.finished
	
	for i: int in range(targets.size()):
		var target: Control = targets[i]
		var current_text: String = text_messages[i] if i < text_messages.size() else ""
		
		if i > 0:
			var prev_target: Control = targets[i - 1]
			
			if target != prev_target:
				if is_instance_valid(tutorial_label):
					tutorial_label.hide()
					
				var next_uv: Vector2 = _get_control_screen_uv(target)
				var next_size: Vector2 = _get_control_hole_size(target, padding)
				
				if tween:
					tween.kill()
				tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
				
				tween.tween_property(shader_material, "shader_parameter/center_position", next_uv, 1.2)
				tween.tween_property(shader_material, "shader_parameter/hole_size", next_size, 1.2)
				
				await tween.finished
		
		_update_label_for_target(current_text)
		await _wait_for_player_click()
	
	if is_instance_valid(tutorial_label):
		tutorial_label.hide()

	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(shader_material, "shader_parameter/hole_size", Vector2(1.0, 1.0), 0.6)
	await tween.finished
	
	overlay_rect.hide()

func _update_label_for_target(text: String) -> void:
	if not is_instance_valid(tutorial_label) or text.is_empty():
		return
	tutorial_label.hide()
	tutorial_label.text = text
	tutorial_label.reset_size()
	await get_tree().process_frame
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var label_x: float = (viewport_size.x * 0.5) - (tutorial_label.size.x * 0.5)
	var label_y: float = viewport_size.y - tutorial_label.size.y - 40.0
	
	tutorial_label.global_position = Vector2(label_x, label_y)
	tutorial_label.show()

func _get_control_screen_uv(target: Control) -> Vector2:
	var global_transform: Transform2D = target.get_global_transform_with_canvas()
	var top_left_pixel: Vector2 = global_transform.origin
	var scaled_size: Vector2 = target.size * global_transform.get_scale()
	var center_pixel_pos: Vector2 = top_left_pixel + (scaled_size * 0.5)
	
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	return center_pixel_pos / viewport_size

func _get_control_hole_size(target: Control, padding_pixels: float) -> Vector2:
	var global_transform: Transform2D = target.get_global_transform_with_canvas()
	var scaled_size: Vector2 = target.size * global_transform.get_scale()
	
	var padded_size: Vector2 = scaled_size + Vector2(padding_pixels, padding_pixels)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	
	return (padded_size * 0.5) / viewport_size

func _wait_for_player_click() -> void:
	await get_tree().create_timer(0.1).timeout
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			break
