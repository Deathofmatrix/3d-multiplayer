extends Node
class_name PlayerInput

enum Mode { ON_FOOT, DRIVING_BOAT }
var mode = Mode.ON_FOOT
var boat_ref: Boat = null

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
	input_vector = player._camera_controller.transform.basis * input_vector
	input_vector.y = 0.0
	player_controller.move_direction = input_vector
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player_controller.jump_requested = true
	
	if Input.is_action_just_pressed("interact"):
		_try_interact()


func _try_interact():
	var ray = player._camera_controller.get_interact_ray()
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.has_method("interact"):
			collider.interact(get_multiplayer_authority())


func _handle_boat_input():
	if Input.is_action_just_pressed("interact"):
		_exit_boat()
	
	var throttle = Input.get_axis("move_down", "move_up")
	var steering = Input.get_axis("move_right", "move_left")
	
	if boat_ref:
		if multiplayer.is_server():
			boat_ref.set_drive_input.rpc(throttle, steering)
		else:
			boat_ref.set_drive_input.rpc_id(1, throttle, steering)


func enter_boat(boat: Boat):
	mode = Mode.DRIVING_BOAT
	boat_ref = boat


func _exit_boat():
	print("exit boat")
	if boat_ref:
		if multiplayer.is_server():
			boat_ref._clear_driver()
		else:
			boat_ref.request_clear_driver.rpc_id(1)
	boat_ref = null
	mode = Mode.ON_FOOT
