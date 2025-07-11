extends RigidBody3D
class_name Boat

@export var acceleration := 4.0
@export var max_speed := 10.0
@export var turn_speed := 1.5
@export var current_driver_peer_id: int = -1

var throttle := 0.0
var steering := 0.0
var current_speed := 0.0

func _ready() -> void:
	print ("Boat Authority: " + str(get_multiplayer_authority()))

func interact(player_id: int):
	if current_driver_peer_id != -1:
		return
	if multiplayer.is_server():
		_assign_driver(player_id)
	else:
		request_assign_driver.rpc_id(1, player_id)


@rpc("any_peer", "reliable")
func request_assign_driver(requesting_peer_id: int):
	_assign_driver(requesting_peer_id)


func _assign_driver(driver_peer_id: int):
	current_driver_peer_id = driver_peer_id
	print("Driver assigned!", current_driver_peer_id)
	
	var player = PlayerRegistry.get_player(current_driver_peer_id)
	player.player_input.enter_boat(self)
	print(player.player_input.boat_ref)


@rpc("any_peer", "call_local")
func set_drive_input(throttle_input: float, steering_input: float):
	if multiplayer.get_remote_sender_id() != current_driver_peer_id:
		print("❌ Invalid sender:", multiplayer.get_remote_sender_id(), current_driver_peer_id)
		return
	throttle = throttle_input
	steering = steering_input


@rpc("any_peer", "reliable")
func request_clear_driver():
	_clear_driver()


func _clear_driver():
	current_driver_peer_id = -1
	throttle = 0.0
	steering = 0.0


func _physics_process(delta):
	if !is_multiplayer_authority():
		return
	
	if current_driver_peer_id == -1:
		throttle = 0.0
		steering = 0.0
	
	if abs(throttle) < 0.01:
		current_speed = move_toward(current_speed, 0.0, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, throttle * max_speed, acceleration * delta)
	
	var forward = transform.basis.x
	linear_velocity = forward * current_speed
	
	if current_driver_peer_id != -1:
		var angle = steering * turn_speed * delta
		rotate_y(angle)
