extends Node3D

@onready var static_body_3d: StaticBody3D = $StaticBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	DialogueManager.show_dialogue_balloon(ResourceLoader.load("uid://drjr7eklm23gt"), "start")
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	if ProgressMarkers.has_met_arthur == false:
		disable_node(static_body_3d)
	
func disable_node(node: Node) -> void:
	node.process_mode = 4
	node.hide()

func enable_node(node: Node) -> void:
	node.process_mode = 0
	node.show()
	


func _on_dialogue_ended(dialogue: DialogueResource) -> void:
	if Constants.body_inter and Constants.table_inter and Constants.photo_inter and Constants.calendar_inter:
		DialogueManager.show_dialogue_balloon(ResourceLoader.load("uid://bkgdy3p7ctli2"), "start")
	if Constants.first_office_end:
		DialogueManager.show_dialogue_balloon(ResourceLoader.load("uid://bkgdy3p7ctli2"), "start")
		enable_node(static_body_3d)
		Constants.first_office_end = false
	if Constants.arthur_end:
		DialogueManager.show_dialogue_balloon(ResourceLoader.load("uid://32gg1vy24cek"), "start")
		Constants.arthur_end = false
