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


@export var dim_overlay: ColorRect
@onready var solve_audio: AudioStreamPlayer2D = $SolveAudio

var current_page: int = 0
var journal_busy: bool = false

func _ready() -> void:
	flip_page.hide()
	add_to_group("journal")
	await _refresh_static_spread()
	
func check_and_trigger_pair_cutscene() -> void:
	if journal_busy:
		return
	if left_viewport.get_child_count() > 0:
		var left_node: Node = left_viewport.get_child(0)
		Variables.verified_correct_pages[current_page] = Variables.is_page_filled_correctly(current_page, left_node)
		
	if right_viewport.get_child_count() > 0:
		var right_node: Node = right_viewport.get_child(0)
		Variables.verified_correct_pages[current_page + 1] = Variables.is_page_filled_correctly(current_page + 1, right_node)
		
	var unrevealed_pair: Array[int] = Variables.get_unrevealed_pair()
	if unrevealed_pair.size() == 2:
		journal_busy = true
		await _play_pair_cutscene(unrevealed_pair)
		journal_busy = false
		
func _play_pair_cutscene(pages_pair: Array[int]) -> void:
	dim_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(dim_overlay, "color:a", 0.6, 0.4)
	await fade_tween.finished
	
	for page_idx: int in pages_pair:
		var target_spread_start: int = (page_idx / 2) * 2
		if current_page != target_spread_start:
			await jump_to_page(target_spread_start)
			await get_tree().create_timer(0.3).timeout
			
		var is_left: bool = (page_idx % 2 == 0)
		var vp: SubViewport = left_viewport if is_left else right_viewport
		
		if vp.get_child_count() > 0:
			var page_node: Node = vp.get_child(0)
			await _animate_page_buttons_shine(page_node)
			
			if not (page_idx in Variables.revealed_locked_pages):
				Variables.revealed_locked_pages.append(page_idx)
				
			await _flash_and_swap_to_solved_page(page_idx, vp)
			
	_save_current_spread_state()
			
	var unfade_tween: Tween = create_tween()
	unfade_tween.tween_property(dim_overlay, "color:a", 0.0, 0.4)
	await unfade_tween.finished
	dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
func _flash_and_swap_to_solved_page(page_idx: int, viewport: SubViewport) -> void:
	var flash_in: Tween = create_tween()
	flash_in.tween_property(dim_overlay, "color", Color(1, 1, 1, 1.0), 0.15)
	await flash_in.finished
	
	_populate_viewport(page_idx, viewport)
	
	var flash_out: Tween = create_tween()
	flash_out.tween_property(dim_overlay, "color", Color(0, 0, 0, 0.6), 0.25)
	await flash_out.finished
	
func _animate_page_buttons_shine(page_node: Node) -> void:
	var slots: Array = page_node.find_children("", "PanelContainer", true, false)
	
	for slot: PanelContainer in slots:
		slot.set_script(null)
		
		for child: Node in slot.get_children():
			if child is Button:
				child.mouse_filter = Control.MOUSE_FILTER_IGNORE
				child.pivot_offset = child.size / 2.0
				
				var new_stylebox: StyleBox = child.get_theme_stylebox("normal").duplicate()
				child.add_theme_stylebox_override("normal", new_stylebox)
				child.add_theme_stylebox_override("hover", new_stylebox)
				child.add_theme_stylebox_override("pressed", new_stylebox)
				
				if solve_audio and solve_audio.stream:
					solve_audio.play()
					
				var btn_tween: Tween = create_tween().set_parallel(true)
				btn_tween.tween_property(child, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_BACK)
				btn_tween.tween_property(new_stylebox, "bg_color", Color.WHITE, 0.2)
				btn_tween.tween_method(func(c: Color) -> void:
					child.add_theme_color_override("font_color", c)
					child.add_theme_color_override("font_hover_color", c)
					child.add_theme_color_override("font_pressed_color", c)
					child.add_theme_color_override("font_focus_color", c)
				, child.get_theme_color("font_color"), Color.BLACK, 0.2)
				await btn_tween.finished
				
				var reset_tween: Tween = create_tween()
				reset_tween.tween_property(child, "scale", Vector2.ONE, 0.1)
				await reset_tween.finished
				
				await get_tree().create_timer(0.15).timeout
	
func _on_tab_pressed(chapter_start_page: int) -> void:
	if journal_busy:
		return
	journal_busy = true
	await jump_to_page(chapter_start_page)
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
		var page_data: Dictionary = Constants.PAGE_PATHS[page_index]
		var page: Node = null
		if page_index in Variables.revealed_locked_pages:
			page = page_data["solved"].instantiate()
			viewport.add_child(page)
		else:
			page = page_data["default"].instantiate()
			viewport.add_child(page)
			Variables.restore_page_slots(page_index, page)
			Variables.apply_locked_style_to_page(page, page_index)
			
func _render_page_to_viewport(page_index: int, viewport: SubViewport) -> Texture2D:
	for child: Node in viewport.get_children():
		child.queue_free()
	if page_index >= 0 and page_index < Constants.PAGE_PATHS.size():
		var page_data: Dictionary = Constants.PAGE_PATHS[page_index]
		var page: Node = null
		
		if page_index in Variables.revealed_locked_pages:
			page = page_data["solved"].instantiate()
		else:
			page = page_data["default"].instantiate()
			Variables.restore_page_slots(page_index, page)
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
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Variables.clear_selection()
		
func _on_tab_1_pressed() -> void:
	_on_tab_pressed(Constants.SECTION_PAGES.tab_1)
	
func _on_tab_2_pressed() -> void:
	_on_tab_pressed(Constants.SECTION_PAGES.tab_2)

func _on_prev_corner_pressed() -> void:
	if journal_busy or current_page - 2 < 0:
		return
	journal_busy = true
	await _flip_page(-1)
	journal_busy = false

func _on_next_corner_pressed() -> void:
	if journal_busy or current_page + 2 >= Constants.PAGE_PATHS.size():
		return
	journal_busy = true
	await _flip_page(1)
	journal_busy = false
