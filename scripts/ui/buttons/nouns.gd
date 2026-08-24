extends Button

@export var is_active: bool
@onready var keyword: Button = $"../../HBoxContainer/Keyword"
@onready var keyword_names: GridContainer = $"../../KeywordNames"
@onready var keyword_nouns: GridContainer = $"../../KeywordNouns"
@onready var keyword_verbs: GridContainer = $"../../KeywordVerbs"
@onready var names: Button = $"../Names"
@onready var verbs: Button = $"../Verbs"
@onready var evidence: Button = $"../../HBoxContainer/Evidence"
var KEYWORD_TEXTS: PackedScene = preload("uid://2e02bl5vknkv")

signal nouns_pressed

func _ready() -> void:
	pressed.connect(_on_pressed)
	keyword.keyword_pressed.connect(_on_keyword_pressed)
	names.names_pressed.connect(_on_names_pressed)
	verbs.verbs_pressed.connect(_on_verbs_pressed)
	evidence.evidence_pressed.connect(_on_evidence_pressed)

	if is_active:
		enable_node(keyword_nouns)
		disable_node(keyword_names)
		disable_node(keyword_verbs)
	
func _on_pressed() -> void:
	if not is_active:
		nouns_pressed.emit()
		is_active = true
		
		var nouns: Array = keyword_nouns.get_children()
		var temp: Array = []
		for node: Node in nouns:
			temp.append(node.text)
		for keyword: String in Variables.noun_keywords:
			if keyword not in temp:
				add_noun(keyword)
	
func _on_keyword_pressed() -> void:
	if is_active:
		enable_node(keyword_nouns)

func _on_names_pressed() -> void:
	is_active = false
	custom_minimum_size.y = 30
	disable_node(keyword_nouns)
	enable_node(keyword_names)

func _on_verbs_pressed() -> void:
	is_active = false
	custom_minimum_size.y = 30
	disable_node(keyword_nouns)
	enable_node(keyword_verbs)

func _on_evidence_pressed() -> void:
	if is_active:
		disable_node(keyword_nouns)

func add_noun(keyword: String) -> void:
	var new_keyword: Button = KEYWORD_TEXTS.instantiate()
	new_keyword.text = keyword
	new_keyword.type = "noun"
	keyword_nouns.add_child(new_keyword)

func disable_node(node: Node) -> void:
	node.process_mode = 4
	node.hide()

func enable_node(node: Node) -> void:
	node.process_mode = 0
	node.show()
