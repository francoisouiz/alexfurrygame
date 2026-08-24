extends Button

@export var is_active: bool
@export var evidence_button: Button
@onready var keyword_classes: HBoxContainer = $"../../KeywordClasses"
@onready var evidence_objects: GridContainer = $"../../EvidenceObjects"

signal keyword_pressed

func _ready() -> void:
	pressed.connect(_on_pressed)
	evidence_button.evidence_pressed.connect(_on_evidence_pressed)

	if is_active:
		enable_node(keyword_classes)
		disable_node(evidence_objects)
	
func _on_pressed() -> void:
	if not is_active:
		keyword_pressed.emit()
		is_active = true

func _on_evidence_pressed() -> void:
	is_active = false
	custom_minimum_size.y = 60
	disable_node(keyword_classes)

func disable_node(node: Node) -> void:
	node.process_mode = 4
	node.hide()

func enable_node(node: Node) -> void:
	node.process_mode = 0
	node.show()
