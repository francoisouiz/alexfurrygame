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

@onready var book_close: AudioStreamPlayer2D = $BookClose
@onready var book_open: AudioStreamPlayer2D = $BookOpen


var KEYWORD_TEXTS: PackedScene = preload("uid://2e02bl5vknkv")
var is_journalling: bool = false
var unlocked_words: Array[String] = []

func _ready() -> void:
	_on_names_pressed()
	animation_player.seek(0.0, true)
	Variables.keywordNames = keyword_names
	Variables.keywordNouns = keyword_nouns
	Variables.keywordVerbs = keyword_verbs
	Variables.preview_layer = $DragPreviewLayer

func _on_journal_button_pressed() -> void:
	is_journalling = not is_journalling
	if is_journalling:
		animation_player.play("ui_transition")
		book_open.play()
		await animation_player.animation_finished
	else:
		animation_player.play_backwards("ui_transition")
		book_close.play()
		await animation_player.animation_finished

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
		add_keyword(keyword, temp, "name", Color.DARK_GREEN)


func _on_nouns_pressed() -> void:
	Variables.active_second_button = "nouns"
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
		add_keyword(keyword, temp, "noun", Color.DARK_BLUE)


func _on_verbs_pressed() -> void:
	Variables.active_second_button = "verbs"
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
		add_keyword(keyword, temp, "verb", Color.DARK_RED)
