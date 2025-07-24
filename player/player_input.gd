class_name PlayerInput
extends Node

enum Mode { ON_FOOT, DRIVING_BOAT }

var mode = Mode.ON_FOOT
var boat_ref: Boat = null

@onready var player_controller: PlayerController = $"../PlayerController"
@onready var player: Player = get_parent()


func _process(delta: float) -> void:
	if mode == Mode.ON_FOOT:
		handle_on_foot_input()
	elif mode == Mode.DRIVING_BOAT:
		handle_boat_input()
	else:
		print("Unknown mode: " + str(mode))


func handle_on_foot_input():
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_vector = Vector3(raw_input.x, 0, raw_input.y)
	input_vector = player._camera_controller.transform.basis * input_vector
	input_vector.y = 0.0
	player_controller.move_direction = input_vector
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player_controller.jump_requested = true
	
	if Input.is_action_just_pressed("interact"):
		try_interact()


func try_interact():
	var ray = player._camera_controller.get_interact_ray()
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.has_method("interact"):
			var my_peer_id = multiplayer.get_unique_id()
			print("Player " + str(my_peer_id) + " attempting to interact with: " + str(collider.name))
			collider.interact(my_peer_id)


func handle_boat_input():
	if Input.is_action_just_pressed("interact"):
		exit_boat()
	
	var throttle = Input.get_axis("move_down", "move_up")
	var steering = Input.get_axis("move_right", "move_left")
	
	if boat_ref:
		boat_ref.set_drive_input.rpc(throttle, steering)


func enter_boat(boat: Boat):
	print(str(multiplayer.get_unique_id()) + " entering boat - Mode changing to DRIVING_BOAT")
	mode = Mode.DRIVING_BOAT
	boat_ref = boat
	print("Boat ref set: " + str(boat_ref.name) + ", Mode is now: " + str(mode))


func exit_boat():
	print("exit boat")
	if boat_ref:
		boat_ref.clear_driver.rpc()
	boat_ref = null
	mode = Mode.ON_FOOT
