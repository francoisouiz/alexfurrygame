extends CanvasLayer
## A basic dialogue balloon modified to follow 3D markers for Dialogue Manager.

@export var dialogue_resource: DialogueResource
@export var start_from_cue: String = ""
@export var auto_start: bool = false
@export var will_block_other_input: bool = true
@export var next_action: StringName = &"ui_accept"
@export var skip_action: StringName = &"ui_cancel"

## The 3D marker/node to follow in world space
var custom_target: Node3D = null

@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var balloon: Control = %Balloon
@onready var character_label: RichTextLabel = %CharacterLabel
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var progress: Polygon2D = %Progress

@export var player_character_name: String = "Lucius"

@export var character_portraits: Dictionary = {
	"Remi": preload("uid://c4r26wtsocm0a"),
	"Calim": preload("uid://bf33b6vj4kg0k"),
	"Bryan": preload("uid://cvrw86uc43kyg")
}
@onready var portrait: TextureRect = $Balloon/PanelContainer/HBoxContainer/Portrait


var temporary_game_states: Array = []
var is_waiting_for_input: bool = false
var will_hide_balloon: bool = false
var locals: Dictionary = {}
var _locale: String = TranslationServer.get_locale()
var mutation_cooldown: Timer = Timer.new()
var _keyword_queue: Array[Dictionary] = []
var _is_processing_keywords: bool = false

var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line


func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()


func _process(_delta: float) -> void:
	if is_instance_valid(dialogue_line):
		progress.visible = not dialogue_label.is_typing and dialogue_line.responses.size() == 0 and not dialogue_line.has_tag("voice")
	
	_update_3d_position()
	
func unlock_keyword(keyword_text: String, category: String) -> void:
	var start_pos: Vector2 = balloon.global_position + (balloon.size / 2.0)
	if keyword_text in Variables.unlocked_keywords_history:
		return
	Variables.unlock_keyword(keyword_text, category, start_pos)
	
	_keyword_queue.append({
		"text": keyword_text,
		"start_pos": start_pos,
		"category": category
	})
	
	if not _is_processing_keywords:
		_process_keyword_queue()
		
func _process_keyword_queue() -> void:
	_is_processing_keywords = true
	
	while _keyword_queue.size() > 0:
		var data: Dictionary = _keyword_queue.pop_front()
		
		_animate_keyword_flying_preview(data["text"], data["start_pos"], data["category"])
		
		await get_tree().create_timer(0.15).timeout
		
	_is_processing_keywords = false

func _animate_keyword_flying_preview(keyword_text: String, start_pos: Vector2, category: String) -> void:
	var preview_btn: Button = Button.new()
	preview_btn.text = keyword_text
	preview_btn.top_level = true
	var btn_size: Vector2 = Vector2(110, 40)
	preview_btn.custom_minimum_size = Vector2(110, 40)
	preview_btn.size = Vector2(110, 40)
	preview_btn.pivot_offset = btn_size / 2.0
	preview_btn.global_position = start_pos - Vector2(100, 50)
	preview_btn.z_index = 100
	
	var stylebox: StyleBox = StyleBoxFlat.new()
	match category:
		"name":
			stylebox.bg_color = Color.DARK_GREEN
		"noun":
			stylebox.bg_color = Color.DARK_BLUE
		"verb":
			stylebox.bg_color = Color.DARK_RED
	preview_btn.add_theme_stylebox_override("normal", stylebox)
	preview_btn.add_theme_stylebox_override("hover", stylebox)
	preview_btn.add_theme_stylebox_override("pressed", stylebox)
	preview_btn.add_theme_color_override("font_color", Color.WHITE)
	preview_btn.add_theme_font_size_override("font_size", 20)
	
	add_child(preview_btn)
	
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var target_pos: Vector2 = viewport_size - Vector2(130, 60)
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(preview_btn, "global_position", target_pos, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(preview_btn, "scale", Vector2(1.2, 1.2), 0.2)
	tween.chain().tween_property(preview_btn, "scale", Vector2(1.0, 1.0), 0.3)
	tween.chain().tween_property(preview_btn, "modulate:a", 0.0, 0.3)
	await tween.finished
	preview_btn.queue_free()


func _update_3d_position() -> void:
	if not is_instance_valid(custom_target) or not balloon.visible:
		return

	var camera: Camera3D = get_viewport().get_camera_3d()
	if not camera:
		return
		
	if is_instance_valid(custom_target) and balloon.visible:
		if camera.is_position_behind(custom_target.global_position):
			balloon.visible = false
		else:
			balloon.visible = true
			var screen_pos: Vector2 = camera.unproject_position(custom_target.global_position)
			balloon.global_position = screen_pos - Vector2(balloon.size.x / 2.0, balloon.size.y)
	
	var responses_container: Control = responses_menu.get_parent() as Control
	if is_instance_valid(responses_menu) and responses_menu.visible:
		var player_marker: DialogueMarker3D = DialogueMarker3D.find_for_character(player_character_name)
		
		if is_instance_valid(player_marker):
			if camera.is_position_behind(player_marker.global_position):
				responses_container.visible = false
			else:
				responses_container.visible = true
				var player_screen_pos: Vector2 = camera.unproject_position(player_marker.global_position)
				
				# Position the CenterContainer bottom-center over the player's marker
				responses_container.global_position = player_screen_pos - Vector2(responses_container.size.x / 2.0, responses_container.size.y)

	# Hide balloon if target is behind the camera
	if camera.is_position_behind(custom_target.global_position):
		balloon.visible = false
		return

	balloon.visible = true
	var screen_pos: Vector2 = camera.unproject_position(custom_target.global_position)

	# Center the balloon horizontally and position its bottom edge at the marker
	balloon.global_position = screen_pos - Vector2(balloon.size.x / 2.0, balloon.size.y)


func _unhandled_input(_event: InputEvent) -> void:
	if will_block_other_input:
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio: float = dialogue_label.visible_ratio
		await dialogue_line.refresh()
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start dialogue, optionally passing a 3D target node (like DialogueMarker3D)
func start(with_dialogue_resource: DialogueResource = null, cue: String = "", extra_game_states: Array = [], target_3d: Node3D = null) -> void:
	custom_target = target_3d
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not cue.is_empty():
		start_from_cue = cue
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_cue, temporary_game_states)
	show()


func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	progress.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	character_label.visible = not dialogue_line.character.is_empty()
	character_label.text = tr(dialogue_line.character, "dialogue")
	
	var char_name: String = dialogue_line.character
	
	if character_portraits.has(char_name):
		portrait.texture = character_portraits[char_name]
		portrait.show()
	else:
		portrait.texture = null
		portrait.hide()
	
	if not dialogue_line.character.is_empty():
		custom_target = DialogueMarker3D.find_for_character(dialogue_line.character)
	else:
		custom_target = null

	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses
	
	balloon.reset_size()

	balloon.show()
	will_hide_balloon = false

	# Sync position right as it shows to prevent 1-frame pops
	_update_3d_position()

	dialogue_label.show()
	if not dialogue_line.text.is_empty():
		dialogue_label.type_out()
		await dialogue_label.finished_typing

	if dialogue_line.has_tag("voice"):
		audio_stream_player.stream = load(dialogue_line.get_tag_value("voice"))
		audio_stream_player.play()
		await audio_stream_player.finished
		next(dialogue_line.next_id)
	elif dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()
	elif dialogue_line.time != "":
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals

func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)

#endregion
