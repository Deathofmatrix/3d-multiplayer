extends RigidBody3D
class_name Boat

#@onready var _synchronizer = $MultiplayerSynchronizer

@export var acceleration := 4.0
@export var max_speed := 10.0
@export var turn_speed := 1.5

var current_driver_peer_id: int = -1
var throttle := 0.0
var steering := 0.0
var current_speed := 0.0


func interact(player):
	if current_driver_peer_id != -1:
		return
	assign_driver(player)


@rpc("any_peer", "call_local", "reliable")
func assign_driver(player: Player):
	if current_driver_peer_id != -1:
		return
	current_driver_peer_id = player.get_multiplayer_authority()
	player.player_input.enter_boat(self)
	print("Driver assigned!", current_driver_peer_id)


@rpc("any_peer", "call_local")
func set_drive_input(throttle_input: float, steering_input: float):
	if multiplayer.get_remote_sender_id() != current_driver_peer_id:
		return
	throttle = throttle_input
	print(throttle)
	steering = steering_input
	print(steering)


@rpc("any_peer", "call_local", "reliable")
func clear_driver():
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
