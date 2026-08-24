extends CanvasLayer

@onready var journal: Panel = $Journal

var is_journalling: bool = false

func _ready() -> void:
	disable_node(journal)

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
