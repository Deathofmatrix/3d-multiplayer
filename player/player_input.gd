extends Node
class_name PlayerInput

enum Mode { ON_FOOT, DRIVING_BOAT }
var mode = Mode.ON_FOOT
var boat_ref: Node = null

@onready var player_controller: PlayerController = $"../PlayerController"
@onready var player: Player = get_parent()


func _process(delta: float) -> void:
	if mode == Mode.ON_FOOT:
		_handle_on_foot_input()
	elif mode == Mode.DRIVING_BOAT:
		_handle_boat_input()


func _handle_on_foot_input():
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_vector = Vector3(raw_input.x, 0, raw_input.y)
	player._camera_controller.transform.basis * input_vector
	input_vector.y = 0.0
	player_controller.move_direction = input_vector
	
	if Input.is_action_just_pressed("interact"):
		_try_interact()


func _try_interact():
	var ray = player._camera_controller.get_interact_ray()
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.has_method("interact"):
			collider.interact(player)


func _handle_boat_input():
	pass
