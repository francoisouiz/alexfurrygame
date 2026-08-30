extends CanvasLayer

@onready var journal: Node = $Journal

@onready var keyword_classes: HBoxContainer = $SideBar/VBoxContainer/KeywordClasses
@onready var names: Button = $SideBar/VBoxContainer/KeywordClasses/Names
@onready var nouns: Button = $SideBar/VBoxContainer/KeywordClasses/Nouns
@onready var verbs: Button = $SideBar/VBoxContainer/KeywordClasses/Verbs

@onready var keyword_names: GridContainer = $SideBar/VBoxContainer/KeywordNames
@onready var keyword_nouns: GridContainer = $SideBar/VBoxContainer/KeywordNouns
@onready var keyword_verbs: GridContainer = $SideBar/VBoxContainer/KeywordVerbs

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var map_animation: AnimationPlayer = $Map/MapAnimation
@onready var journal_button: Button = $JournalButton

@onready var book_close: AudioStreamPlayer2D = $BookClose
@onready var book_open: AudioStreamPlayer2D = $BookOpen

@onready var bahay: Button = $Map/Bahay
@onready var dim_overlay: ColorRect = $DimOverlay
@onready var side_bar: Panel = $SideBar
@onready var spot_light: CanvasLayer = $SpotLight
@onready var texture_rect: TextureRect = $SideBar/TextureRect
@onready var file_animation: AnimationPlayer = $FileCase/FileAnimation


var KEYWORD_TEXTS: PackedScene = preload("uid://2e02bl5vknkv")
var is_journalling: bool = false
var on_map: bool = false
var on_file: bool = false
var unlocked_words: Array[String] = []

func _ready() -> void:
	_on_names_pressed()
	animation_player.seek(0.0, true)
	Variables.keywordNames = keyword_names
	Variables.keywordNouns = keyword_nouns
	Variables.keywordVerbs = keyword_verbs
	Variables.preview_layer = $DragPreviewLayer
	Constants.open_map.connect(_on_open_map)
	Constants.journal_prompt.connect(_on_journal_prompt)
	Constants.first_time_signal.connect(_on_first_time)
	Constants.file_case.connect(_on_file_case)
	if not Constants.has_opened_journal:
		disable_node(journal_button)
		
func _on_file_case() -> void:
	file_animation.play("file_animation")
	await file_animation.animation_finished
	on_file = true

func _on_open_map() -> void:
	map_animation.play("map_animation")
	await map_animation.animation_finished
	on_map = true
	
func _on_first_time() -> void:
	journal.z_index = 2
	side_bar.z_index = 1
	journal_button.z_index = 2
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(dim_overlay, "color:a", 0.6, 0.4)
	await fade_tween.finished
	var ui_sequence: Array[Control] = [journal, journal, journal]
	var messages: Array[String] = [
		"This info may or may not be correct.",
		"Correct pages will be revealed in pairs of two.",
		"Correctly fill out another page in the future to identify if this page is correct."
	]
	await spot_light.start_spotlight_sequence(ui_sequence, messages)
	Constants.has_opened_journal = true
	var unfade_tween: Tween = create_tween()
	unfade_tween.tween_property(dim_overlay, "color:a", 0.0, 0.4)
	await unfade_tween.finished
	dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	journal.z_index = 0
	side_bar.z_index = 0
	journal_button.z_index = 0
	
func _on_journal_prompt() -> void:
	if not Constants.has_opened_journal:
		enable_node(journal_button)
		_on_journal_button_pressed()
		dim_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
		journal.z_index = 2
		side_bar.z_index = 1
		journal_button.z_index = 2
		var fade_tween: Tween = create_tween()
		fade_tween.tween_property(dim_overlay, "color:a", 0.6, 0.4)
		await fade_tween.finished
		var ui_sequence: Array[Control] = [journal, side_bar, side_bar, side_bar, journal, journal, journal_button]
		var messages: Array[String] = [
			"This is your journal. This is where you'll be working.",
			"On the side are tabs for names, nouns, and verbs.",
			"As you explore, keywords will be placed in this sidebar.",
			"You can fill out your journal by dragging these keywords into empty slots.",
			"You can also click a word from the sidebar and click again on the target slot.",
			"Explore around the office to fill out the first page.",
			"Toggle between exploring and journalling with this button."
		]
		await spot_light.start_spotlight_sequence(ui_sequence, messages)
		Constants.has_opened_journal = true
		var unfade_tween: Tween = create_tween()
		unfade_tween.tween_property(dim_overlay, "color:a", 0.0, 0.4)
		await unfade_tween.finished
		dim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		journal.z_index = 0
		side_bar.z_index = 0
		journal_button.z_index = 0
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit_map") and on_map:
		map_animation.play_backwards("map_animation")
		await map_animation.animation_finished
		on_map = false
	if event.is_action_pressed("exit_map") and on_file:
		file_animation.play_backwards("file_animation")
		await file_animation.animation_finished
		on_file = false


func _on_journal_button_pressed() -> void:
	is_journalling = not is_journalling
	if is_journalling:
		match Variables.active_second_button:
			"names":
				_on_names_pressed()
			"nouns":
				_on_nouns_pressed()
			"verbs":
				_on_verbs_pressed()
		animation_player.play("ui_transition")
		book_open.play()
		await animation_player.animation_finished
	else:
		animation_player.play_backwards("ui_transition")
		book_close.play()
		await animation_player.animation_finished
	journal.save_current_spread_state()

func disable_node(node: Node) -> void:
	node.process_mode = 4
	node.hide()

func enable_node(node: Node) -> void:
	node.process_mode = 0
	node.show()
			
func add_keyword(keyword: String, temp: Array, type: String, color: Color) -> void:
	if keyword not in temp and keyword not in unlocked_words:
		var new_keyword: Button = KEYWORD_TEXTS.instantiate()
		new_keyword.text = keyword
		new_keyword.type = type
		var stylebox: StyleBoxFlat = new_keyword.get_theme_stylebox("normal").duplicate()
		stylebox.bg_color = color
		new_keyword.add_theme_stylebox_override("normal", stylebox)
		new_keyword.add_theme_stylebox_override("hover", stylebox)
		new_keyword.add_theme_stylebox_override("pressed", stylebox)
		unlocked_words.append(keyword)
		match type:
			"name":
				keyword_names.add_child(new_keyword)
			"noun":
				keyword_nouns.add_child(new_keyword)
			"verb":
				keyword_verbs.add_child(new_keyword)

func _on_names_pressed() -> void:
	Variables.active_second_button = "names"
	texture_rect.texture = preload("uid://dlp7cs4x8dk2t")
	enable_node(keyword_names)
	nouns.custom_minimum_size.y = 50
	disable_node(keyword_nouns)
	verbs.custom_minimum_size.y = 50
	disable_node(keyword_verbs)
	
	var node_names: Array[Node] = keyword_names.get_children()
	var temp: Array[String] = []
	for node: Node in node_names:
		temp.append(node.text)
	for keyword: String in Variables.name_keywords:
		add_keyword(keyword, temp, "name", Color("ac3232"))


func _on_nouns_pressed() -> void:
	Variables.active_second_button = "nouns"
	texture_rect.texture = preload("uid://djfs1xld2p25p")
	enable_node(keyword_nouns)
	
	names.custom_minimum_size.y = 50
	disable_node(keyword_names)
	verbs.custom_minimum_size.y = 50
	disable_node(keyword_verbs)
	
	var node_nouns: Array[Node] = keyword_nouns.get_children()
	var temp: Array[String] = []
	for node: Node in node_nouns:
		temp.append(node.text)
	for keyword: String in Variables.noun_keywords:
		add_keyword(keyword, temp, "noun", Color("df7126"))


func _on_verbs_pressed() -> void:
	Variables.active_second_button = "verbs"
	texture_rect.texture = preload("uid://dq8s0ka8rsymg")
	enable_node(keyword_verbs)
	
	names.custom_minimum_size.y = 50
	disable_node(keyword_names)
	nouns.custom_minimum_size.y = 50
	disable_node(keyword_nouns)
	
	var node_verbs: Array[Node] = keyword_verbs.get_children()
	var temp: Array[String] = []
	for node: Node in node_verbs:
		temp.append(node.text)
	for keyword: String in Variables.verb_keywords:
		add_keyword(keyword, temp, "verb", Color("37946e"))


func _on_bahay_pressed() -> void:
	SceneLoader.load_scene(Constants.SCENE_PATHS.bahay)
