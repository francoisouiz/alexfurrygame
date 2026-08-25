extends Control


@onready var flip_page: Sprite2D = $PageStack/FlipPage
@onready var left_viewport: SubViewport = $PageStack/LeftPageContainer/LeftViewport
@onready var right_viewport: SubViewport = $PageStack/RightPageContainer/RightViewport

@onready var flip_front_vp: SubViewport = $Viewports/FlipFrontViewport
@onready var flip_back_vp: SubViewport = $Viewports/FlipBackViewport
const PAGE_0: PackedScene = preload("uid://c1nmk7xyjwyx6")
const PAGE_1: PackedScene = preload("uid://b6hian7r3poy7")

var page_scenes: Array[PackedScene] = [PAGE_0, PAGE_1]
var current_page: int = 0

func _ready() -> void:
	print("viewport size: ", get_viewport().size)
	await _refresh_static_spread()

func _populate_viewport(page_index: int, viewport: SubViewport) -> void:
	for child: Node in viewport.get_children():
		child.queue_free()
	if page_index >= 0 and page_index < page_scenes.size():
		var page: Node = page_scenes[page_index].instantiate()
		viewport.add_child(page)
	
func _flip_page(direction: int, duration: float = 0.4) -> void:
	var flip_mat: ShaderMaterial = flip_page.material
	var front_ind: int = current_page if direction > 0 else current_page - 1
	var back_ind: int  = current_page + 1 if direction > 0 else current_page - 2

	flip_mat.set_shader_parameter("front_tex", await _populate_viewport(front_ind, flip_front_vp))
	flip_mat.set_shader_parameter("back_tex", await _populate_viewport(back_ind, flip_back_vp))
	flip_page.show()

	var tween: Tween = create_tween()
	tween.tween_method(func(p: float) -> void: flip_mat.set_shader_parameter("progress", p), 0.0, 1.0, duration)
	await tween.finished

	current_page += direction * 2
	flip_page.hide()
	_refresh_static_spread()
	
func _refresh_static_spread() -> void:
	var left_index: int = current_page
	var right_index: int = current_page + 1
	
	_populate_viewport(left_index, left_viewport)
	_populate_viewport(right_index, right_viewport)
		
func jump_to_page(target: int) -> void:
	var distance: int = absi(target - current_page)
	var direction: int = sign(target - current_page)
	if distance <= 2:
		await _flip_page(direction)
		return
		
	var leaves_to_turn: int = distance / 2 
	var total_time: float = clamp(leaves_to_turn * 0.05, 0.4, 1.2)
	var per_flip: float = total_time / leaves_to_turn

	for i: int in leaves_to_turn:
		var dur: float
		if i < leaves_to_turn - 2:
			dur = per_flip
		else:
			dur = 0.35
		await _flip_page(direction, dur)
