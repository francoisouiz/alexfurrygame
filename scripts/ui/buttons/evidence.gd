extends Button

@export var is_active: bool
@export var keyword_button: Button
@onready var keyword_classes: HBoxContainer = $"../../KeywordClasses"
@onready var evidence_objects: GridContainer = $"../../EvidenceObjects"

signal evidence_pressed

func _ready() -> void:
	pressed.connect(_on_pressed)
	keyword_button.keyword_pressed.connect(_on_keyword_pressed)

	if is_active:
		enable_node(evidence_objects)
	
func _on_pressed() -> void:
	if not is_active:
		evidence_pressed.emit()
		is_active = true
		enable_node(evidence_objects)

func _on_keyword_pressed() -> void:
	is_active = false
	custom_minimum_size.y = 60
	disable_node(evidence_objects)
	enable_node(keyword_classes)

func disable_node(node: Node) -> void:
	node.process_mode = 4
	node.hide()

func enable_node(node: Node) -> void:
	node.process_mode = 0
	node.show()
