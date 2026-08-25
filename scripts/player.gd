extends CharacterBody3D

@export var speed: float = 7.0
@onready var interaction_area: Area3D = $InteractionArea

var current_actionable: DialogueActionable3D = null

func _ready() -> void:
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_instance_valid(current_actionable):
		get_viewport().set_input_as_handled()
		current_actionable.action()

func _on_interaction_area_entered(area: Area3D) -> void:
	if area is DialogueActionable3D:
		current_actionable = area

func _on_interaction_area_exited(area: Area3D) -> void:
	if area == current_actionable:
		_update_current_actionable()

func _update_current_actionable() -> void:
	current_actionable = null
	var overlapping_areas: Array[Area3D] = interaction_area.get_overlapping_areas()
	
	for area: Area3D in overlapping_areas:
		if area is DialogueActionable3D:
			current_actionable = area
			break

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()
