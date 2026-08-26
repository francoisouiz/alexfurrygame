extends Node

var active_first_button: String
var active_second_button: String
var name_keywords: Array = ["Daniel", "Jacob", "Calim", "Villalobos", "Francesca"]
var noun_keywords: Array = ["peanits"]
var verb_keywords: Array = ["sucked"]
var evidence: Array = []
var keywordNames: GridContainer
var keywordNouns: GridContainer
var keywordVerbs: GridContainer
var preview_layer: Control

var page_slot_states: Dictionary = {}

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
					"type": child.type
				})
				break
				
	page_slot_states[page_index] = saved_data

func restore_page_slots(page_index: int, page_node: Node) -> void:
	if not page_slot_states.has(page_index):
		return
		
	var slots: Array = page_node.find_children("", "PanelContainer", true, false)
	var saved_data: Array = page_slot_states[page_index]
	
	for item: Dictionary in saved_data:
		var idx: int = item["slot_index"]
		if idx < slots.size():
			var target_slot: PanelContainer = slots[idx]
			
			var btn: Button = load("uid://2e02bl5vknkv").instantiate()
			btn.text = item["text"]
			btn.type = item["type"]
			
			target_slot.add_child(btn)
			btn.custom_minimum_size = Vector2.ZERO
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
