extends Control


@onready var flip_page: Sprite2D = $PageStack/FlipPage
@onready var left_viewport: SubViewport = $PageStack/LeftPageContainer/LeftViewport
@onready var right_viewport: SubViewport = $PageStack/RightPageContainer/RightViewport
@onready var left_page_container: SubViewportContainer = $PageStack/LeftPageContainer
@onready var right_page_container: SubViewportContainer = $PageStack/RightPageContainer

@onready var flip_front_vp: SubViewport = $Viewports/FlipFrontViewport
@onready var flip_back_vp: SubViewport = $Viewports/FlipBackViewport
@onready var prev_corner: TextureButton = $PageStack/PrevCorner
@onready var next_corner: TextureButton = $PageStack/NextCorner

var current_page: int = 0
var journal_busy: bool = false

func _ready() -> void:
	flip_page.hide()
	prev_corner.pressed.connect(_on_prev_corner_pressed)
	next_corner.pressed.connect(_on_next_corner_pressed)
	await _refresh_static_spread()
	
func _on_prev_corner_pressed() -> void:
	if journal_busy or current_page - 2 < 0:
		return
	journal_busy = true
	await _flip_page(-1)
	journal_busy = false
	
func _on_tab_pressed(chapter_start_page: int) -> void:
	if journal_busy:
		return
	journal_busy = true
	await jump_to_page(chapter_start_page)
	journal_busy = false

func _on_next_corner_pressed() -> void:
	if journal_busy or current_page + 2 >= Constants.PAGE_PATHS.size():
		return
	journal_busy = true
	await _flip_page(1)
	journal_busy = false
	
func _save_current_spread_state() -> void:
	if left_viewport.get_child_count() > 0:
		Variables.save_page_slots(current_page, left_viewport.get_child(0))
	if right_viewport.get_child_count() > 0:
		Variables.save_page_slots(current_page + 1, right_viewport.get_child(0))

func _populate_viewport(page_index: int, viewport: SubViewport) -> void:
	for child: Node in viewport.get_children():
		child.queue_free()
	if page_index >= 0 and page_index < Constants.PAGE_PATHS.size():
		var page: Node = Constants.PAGE_PATHS[page_index].instantiate()
		viewport.add_child(page)
		Variables.restore_page_slots(page_index, page)

func _render_page_to_viewport(page_index: int, viewport: SubViewport) -> Texture2D:
	for child: Node in viewport.get_children():
		child.queue_free()
	if page_index >= 0 and page_index < Constants.PAGE_PATHS.size():
		var page: Node = Constants.PAGE_PATHS[page_index].instantiate()
		viewport.add_child(page)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	return viewport.get_texture()

func _flip_page(direction: int, duration: float = 0.4) -> void:
	_save_current_spread_state()
	var flip_mat: ShaderMaterial = flip_page.material
	var front_ind: int
	var back_ind: int
	if direction > 0:
		front_ind = current_page + 1
		back_ind = current_page + 2
	else:
		front_ind = current_page - 1
		back_ind = current_page
	var new_current_page: int = current_page + direction * 2
	

	flip_mat.set_shader_parameter("front_tex", await _render_page_to_viewport(front_ind, flip_front_vp))
	flip_mat.set_shader_parameter("back_tex", await _render_page_to_viewport(back_ind, flip_back_vp))
	flip_mat.set_shader_parameter("direction", float(direction))
	
	if direction > 0:
		_populate_viewport(new_current_page + 1, right_viewport)
	else:
		_populate_viewport(new_current_page, left_viewport)
	
	flip_page.show()
	var tween: Tween = create_tween()
	tween.tween_method(func(p: float) -> void: flip_mat.set_shader_parameter("progress", p), 0.0, 1.0, duration)
	await tween.finished

	current_page = new_current_page
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

func _on_tab_1_pressed() -> void:
	_on_tab_pressed(Constants.SECTION_PAGES.tab_1)

func _on_tab_2_pressed() -> void:
	_on_tab_pressed(Constants.SECTION_PAGES.tab_2)
