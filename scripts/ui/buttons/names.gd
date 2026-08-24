extends Button

@export var is_active: bool
@onready var keyword: Button = $"../../HBoxContainer/Keyword"
@onready var keyword_names: GridContainer = $"../../KeywordNames"
@onready var keyword_nouns: GridContainer = $"../../KeywordNouns"
@onready var keyword_verbs: GridContainer = $"../../KeywordVerbs"
@onready var nouns: Button = $"../Nouns"
@onready var verbs: Button = $"../Verbs"
@onready var evidence: Button = $"../../HBoxContainer/Evidence"
var KEYWORD_TEXTS: PackedScene = preload("uid://2e02bl5vknkv")

signal names_pressed

func _ready() -> void:
	pressed.connect(_on_pressed)
	keyword.keyword_pressed.connect(_on_keyword_pressed)
	nouns.nouns_pressed.connect(_on_nouns_pressed)
	verbs.verbs_pressed.connect(_on_verbs_pressed)
	evidence.evidence_pressed.connect(_on_evidence_pressed)

	if is_active:
		enable_node(keyword_names)
		for keyword: String in Variables.name_keywords:
			add_name(keyword)
		disable_node(keyword_nouns)
		disable_node(keyword_verbs)
	
func _on_pressed() -> void:
	if not is_active:
		names_pressed.emit()
		is_active = true
		
		var nouns: Array = keyword_names.get_children()
		var temp: Array = []
		for node: Node in nouns:
			temp.append(node.text)
		for keyword: String in Variables.name_keywords:
			if keyword not in temp:
				add_name(keyword)
	
func _on_keyword_pressed() -> void:
	if is_active:
		enable_node(keyword_names)

func _on_nouns_pressed() -> void:
	is_active = false
	custom_minimum_size.y = 30
	disable_node(keyword_names)
	enable_node(keyword_nouns)

func _on_verbs_pressed() -> void:
	is_active = false
	custom_minimum_size.y = 30
	disable_node(keyword_names)
	enable_node(keyword_verbs)

func _on_evidence_pressed() -> void:
	if is_active:
		disable_node(keyword_names)

func add_name(keyword: String) -> void:
	var new_keyword: Button = KEYWORD_TEXTS.instantiate()
	new_keyword.text = keyword
	new_keyword.type = "name"
	keyword_names.add_child(new_keyword)

func disable_node(node: Node) -> void:
	node.process_mode = 4
	node.hide()

func enable_node(node: Node) -> void:
	node.process_mode = 0
	node.show()
