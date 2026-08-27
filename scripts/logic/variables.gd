extends Node

signal keyword_unlocked(keyword_text: String, category: String, start_global_pos: Vector2)

var active_first_button: String
var active_second_button: String
var name_keywords: Array = []
var noun_keywords: Array = []
var verb_keywords: Array = []
var evidence: Array = []
var keywordNames: GridContainer
var keywordNouns: GridContainer
var keywordVerbs: GridContainer
var preview_layer: Control

var page_answers: Dictionary = {
	0: ["Jacob", "Calim", "likes", "Errol", "Bayubay"],
	1: ["Bryan", "Daza", "killed", "Errol", "Bayubay"],
	2: ["Bryan", "Daza", "killed", "Errol", "Bayubay"]
}

var verified_correct_pages: Dictionary = {}
var revealed_locked_pages: Array[int] = []
var page_slot_states: Dictionary = {}
var unlocked_keywords_history: Array[String] = []

var selected_slot: PanelContainer = null
var selected_sidebar_button: Button = null

func unlock_keyword(keyword_text: String, category: String, start_global_pos: Vector2 = Vector2.ZERO) -> void:
	if keyword_text in unlocked_keywords_history:
		return
		
	unlocked_keywords_history.append(keyword_text)
	
	match category.to_lower():
		"name", "names":
			if not keyword_text in name_keywords:
				name_keywords.append(keyword_text)
		"noun", "nouns":
			if not keyword_text in noun_keywords:
				noun_keywords.append(keyword_text)
		"verb", "verbs":
			if not keyword_text in verb_keywords:
				verb_keywords.append(keyword_text)
				
	keyword_unlocked.emit(keyword_text, category, start_global_pos)

func try_click_placement() -> void:
	if selected_slot != null and selected_sidebar_button != null:
		if "is_locked" in selected_slot and selected_slot.is_locked:
			_clear_click_selection()
			return
			
		_clear_slot_buttons(selected_slot)
		
		var new_button: Button = selected_sidebar_button.duplicate()
		if "type" in selected_sidebar_button:
			new_button.type = selected_sidebar_button.type
		new_button.text = selected_sidebar_button.text
		
		selected_slot.add_child(new_button)
		_fit_button(new_button)
		_clear_click_selection()
		_notify_journal_check()

func try_slot_to_slot_transfer(target_slot: PanelContainer) -> void:
	if selected_slot == null or selected_slot == target_slot:
		return
		
	if ("is_locked" in selected_slot and selected_slot.is_locked) or ("is_locked" in target_slot and target_slot.is_locked):
		_clear_click_selection()
		return
		
	var source_button: Button = _get_slot_button(selected_slot)
	var target_button: Button = _get_slot_button(target_slot)
	
	if source_button == null:
		_clear_click_selection()
		selected_slot = target_slot
		if target_slot.has_method("set_highlight"):
			target_slot.set_highlight(true)
		return
		
		
	selected_slot.remove_child(source_button)
	if target_button != null:
		target_slot.remove_child(target_button)
		
		
	target_slot.add_child(source_button)
	_fit_button(source_button)
	
	if target_button != null:
		selected_slot.add_child(target_button)
		_fit_button(target_button)
		
	_clear_click_selection()
	_notify_journal_check()
	
func _get_slot_button(slot: PanelContainer) -> Button:
	for child: Node in slot.get_children():
		if child is Button:
			return child
	return null
	
func select_sidebar_button(btn: Button) -> void:
	selected_sidebar_button = btn	
	if selected_slot != null:
		try_click_placement()
	else:
		print("Selected sidebar button first: ", btn.text)
		
func clear_selection() -> void:
	if selected_slot and selected_slot.has_method("set_highlight"):
		selected_slot.set_highlight(false)
	selected_slot = null
	selected_sidebar_button = null
	
func _clear_slot_buttons(slot: PanelContainer) -> void:
	for child: Node in slot.get_children():
		if child is Button:
			slot.remove_child(child)
			child.queue_free()
			
func _fit_button(button: Button) -> void:
	button.custom_minimum_size = Vector2.ZERO
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
func _clear_click_selection() -> void:
	if selected_slot and selected_slot.has_method("set_highlight"):
		selected_slot.set_highlight(false)
	selected_slot = null
	selected_sidebar_button = null
	
func _notify_journal_check() -> void:
	var journal: Node = Engine.get_main_loop().root.get_tree().get_first_node_in_group("journal")
	if journal and journal.has_method("check_and_trigger_pair_cutscene"):
		journal.check_and_trigger_pair_cutscene()

func _find_first_empty_slot(journal: Node) -> PanelContainer:
	var left_vp: SubViewport = journal.get_node_or_null("PageStack/LeftPageContainer/LeftViewport")
	var right_vp: SubViewport = journal.get_node_or_null("PageStack/RightPageContainer/RightViewport")
	
	var search_viewports: Array = [left_vp, right_vp]

	for vp: SubViewport in search_viewports:
		if vp and vp.get_child_count() > 0:
			var page_node: Node = vp.get_child(0)
			var slots: Array = page_node.find_children("", "PanelContainer", true, false)
			
			for slot: PanelContainer in slots:
				if "is_locked" in slot and slot.is_locked:
					continue
					
				var has_button: bool = false
				for child: Node in slot.get_children():
					if child is Button:
						has_button = true
						break
						
				if not has_button:
					return slot
	return null
		
func apply_locked_style_to_page(page_node: Node, page_idx: int) -> void:
	if not (page_idx in revealed_locked_pages):
		return
		
	if not page_node.is_node_ready():
		await page_node.ready
		
	var slots: Array = page_node.find_children("", "PanelContainer", true, false)
	
	for slot: PanelContainer in slots:
		slot.set_script(null)
		if "is_locked" in slot:
			slot.is_locked = true
		
		for child: Node in slot.get_children():
			if child is Button:
				child.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				var new_stylebox: StyleBoxFlat = StyleBoxFlat.new()
				new_stylebox.bg_color = Color.WHITE
				
				child.add_theme_stylebox_override("normal", new_stylebox)
				child.add_theme_stylebox_override("hover", new_stylebox)
				child.add_theme_stylebox_override("pressed", new_stylebox)
				
				var black_text: Color = Color.BLACK
				child.add_theme_color_override("font_color", black_text)
				child.add_theme_color_override("font_hover_color", black_text)
				child.add_theme_color_override("font_pressed_color", black_text)
				child.add_theme_color_override("font_focus_color", black_text)

func is_page_filled_correctly(page_index: int, page_node: Node) -> bool:
	if not page_answers.has(page_index):
		return false
	var required: Array = page_answers[page_index]
	var slots: Array = page_node.find_children("", "PanelContainer", true, false)
	
	if slots.size() < required.size():
		return false
		
	for i: int in required.size():
		var slot: PanelContainer = slots[i]
		var btn: Button = null
		for child: Node in slot.get_children():
			if child is Button:
				btn = child
				break
		if btn == null or btn.text.to_lower() != required[i].to_lower():
			return false
	return true
	
func get_unrevealed_pair() -> Array[int]:
	var unrevealed: Array[int] = []
	for page_idx: int in verified_correct_pages.keys():
		if page_idx in revealed_locked_pages:
			continue
			
		if verified_correct_pages[page_idx] == true:
			unrevealed.append(page_idx)
			
		if unrevealed.size() == 2:
			return unrevealed
			
	return []

func save_page_slots(page_index: int, page_node: Node) -> void:
	if page_index < 0:
		return
	
	var slots: Array = page_node.find_children("", "PanelContainer", true, false)
	var saved_data: Array[Dictionary] = []
	
	for i: int in slots.size():
		var slot: PanelContainer = slots[i]
		for child: Node in slot.get_children():
			if child is Button and "type" in child:
				saved_data.append({
					"slot_index": i,
					"text": child.text,
					"type": child.type,
					"stylebox": child.get_theme_stylebox("normal")
				})
				break
				
	page_slot_states[page_index] = saved_data

func restore_page_slots(page_index: int, page_node: Node) -> void:
	if not page_slot_states.has(page_index):
		return
		
	var slots: Array = page_node.find_children("", "PanelContainer", true, false)
	var saved_data: Array = page_slot_states[page_index]
	var is_locked_page: bool = page_index in revealed_locked_pages
	
	for item: Dictionary in saved_data:
		var idx: int = item["slot_index"]
		if idx < slots.size():
			var target_slot: PanelContainer = slots[idx]
			
			for c: Node in target_slot.get_children():
				c.queue_free()
			
			var btn: Button = load("uid://2e02bl5vknkv").instantiate()
			btn.text = item["text"]
			btn.type = item["type"]
			if is_locked_page:
				target_slot.set_script(null)
				if "is_locked" in target_slot:
					target_slot.is_locked = true
				
				btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				var white_stylebox: StyleBox = StyleBoxFlat.new()
				white_stylebox.bg_color = Color.WHITE
				btn.add_theme_stylebox_override("normal", white_stylebox)
				btn.add_theme_stylebox_override("hover", white_stylebox)
				btn.add_theme_stylebox_override("pressed", white_stylebox)
				
				var black_text: Color = Color.BLACK
				btn.add_theme_color_override("font_color", black_text)
				btn.add_theme_color_override("font_hover_color", black_text)
				btn.add_theme_color_override("font_pressed_color", black_text)
				btn.add_theme_color_override("font_focus_color", black_text)
			else:
				var stylebox: StyleBoxFlat = item["stylebox"].duplicate()
				btn.add_theme_stylebox_override("normal", stylebox)
				btn.add_theme_stylebox_override("hover", stylebox)
				btn.add_theme_stylebox_override("pressed", stylebox)
			
			target_slot.add_child(btn)
			btn.custom_minimum_size = Vector2.ZERO
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
