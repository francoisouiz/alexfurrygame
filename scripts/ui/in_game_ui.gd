extends CanvasLayer

@onready var journal: Panel = $Journal
@onready var keyword: Button = $Panel/VBoxContainer/HBoxContainer/Keyword
@onready var evidence: Button = $Panel/VBoxContainer/HBoxContainer/Evidence

@onready var keyword_classes: HBoxContainer = $Panel/VBoxContainer/KeywordClasses
@onready var names: Button = $Panel/VBoxContainer/KeywordClasses/Names
@onready var nouns: Button = $Panel/VBoxContainer/KeywordClasses/Nouns
@onready var verbs: Button = $Panel/VBoxContainer/KeywordClasses/Verbs

@onready var keyword_names: GridContainer = $Panel/VBoxContainer/KeywordNames
@onready var keyword_nouns: GridContainer = $Panel/VBoxContainer/KeywordNouns
@onready var keyword_verbs: GridContainer = $Panel/VBoxContainer/KeywordVerbs

@onready var evidence_objects: GridContainer = $Panel/VBoxContainer/EvidenceObjects

var KEYWORD_TEXTS: PackedScene = preload("uid://2e02bl5vknkv")
var is_journalling: bool = false
var unlocked_words: Array[String] = []

func _ready() -> void:
	_on_keyword_pressed()
	_on_names_pressed()
	disable_node(journal)
	disable_node(evidence_objects)

func _on_journal_button_pressed() -> void:
	is_journalling = not is_journalling
	if is_journalling:
		enable_node(journal)
	else:
		disable_node(journal)

func disable_node(node: Node) -> void:
	node.process_mode = 4
	node.hide()

func enable_node(node: Node) -> void:
	node.process_mode = 0
	node.show()

func _on_keyword_pressed() -> void:
	Variables.active_first_button = "keyword"
	evidence.custom_minimum_size.y = 60
	disable_node(evidence_objects)
	enable_node(keyword_classes)
	
	match Variables.active_second_button:
		"names":
			enable_node(keyword_names)
		"nouns":
			enable_node(keyword_nouns)
		"verbs":
			enable_node(keyword_verbs)

func _on_evidence_pressed() -> void:
	Variables.active_first_button = "evidence"
	enable_node(evidence_objects)
	keyword.custom_minimum_size.y = 60
	disable_node(keyword_classes)
	
	match Variables.active_second_button:
		"names":
			disable_node(keyword_names)
		"nouns":
			disable_node(keyword_nouns)
		"verbs":
			disable_node(keyword_verbs)

func _on_names_pressed() -> void:
	Variables.active_second_button = "names"
	enable_node(keyword_names)
	
	nouns.custom_minimum_size.y = 30
	disable_node(keyword_nouns)
	verbs.custom_minimum_size.y = 30
	disable_node(keyword_verbs)
	
	var node_names: Array[Node] = keyword_names.get_children()
	var temp: Array[String] = []
	for node: Node in node_names:
		temp.append(node.text)
	for keyword: String in Variables.name_keywords:
		if keyword not in temp and keyword not in unlocked_words:
			var new_keyword: Button = KEYWORD_TEXTS.instantiate()
			new_keyword.text = keyword
			new_keyword.type = "name"
			unlocked_words.append(keyword)
			keyword_names.add_child(new_keyword)


func _on_nouns_pressed() -> void:
	Variables.active_second_button = "nouns"
	enable_node(keyword_nouns)
	
	names.custom_minimum_size.y = 30
	disable_node(keyword_names)
	verbs.custom_minimum_size.y = 30
	disable_node(keyword_verbs)
	
	var node_nouns: Array[Node] = keyword_nouns.get_children()
	var temp: Array[String] = []
	for node: Node in node_nouns:
		temp.append(node.text)
	for keyword: String in Variables.noun_keywords:
		if keyword not in temp and keyword not in unlocked_words:
			var new_keyword: Button = KEYWORD_TEXTS.instantiate()
			new_keyword.text = keyword
			new_keyword.type = "noun"
			unlocked_words.append(keyword)
			keyword_nouns.add_child(new_keyword)


func _on_verbs_pressed() -> void:
	Variables.active_second_button = "verbs"
	enable_node(keyword_verbs)
	
	names.custom_minimum_size.y = 30
	disable_node(keyword_names)
	nouns.custom_minimum_size.y = 30
	disable_node(keyword_nouns)
	
	var node_verbs: Array[Node] = keyword_verbs.get_children()
	var temp: Array[String] = []
	for node: Node in node_verbs:
		temp.append(node.text)
	for keyword: String in Variables.verb_keywords:
		if keyword not in temp and keyword not in unlocked_words:
			var new_keyword: Button = KEYWORD_TEXTS.instantiate()
			new_keyword.text = keyword
			new_keyword.type = "verb"
			unlocked_words.append(keyword)
			keyword_verbs.add_child(new_keyword)
