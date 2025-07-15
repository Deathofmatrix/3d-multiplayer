extends RigidBody3D
class_name Boat

@export var acceleration := 5.0
@export var max_speed := 15.0
@export var turn_speed := 10.0
@export var drag_coefficient := 0.95
@export var water_resistance := 2.0

@export var current_driver_peer_id: int = -1

var throttle := 0.0
var steering := 0.0
var current_speed := 0.0


func _ready() -> void:
	# Set server as authority for the boat
	if multiplayer.is_server():
		set_multiplayer_authority(1)  # Server ID is typically 1
	print("Boat Authority: " + str(get_multiplayer_authority()))


func interact(player_id: int):
	if current_driver_peer_id != -1:
		return
	assign_driver.rpc(player_id)


@rpc("any_peer", "call_local", "reliable")
func assign_driver(driver_peer_id: int):
	print("assigning driver, caller: " + str(multiplayer.get_remote_sender_id()))
	if not multiplayer.is_server(): 
		return
	
	# Additional validation: ensure the caller has permission
	var caller_id = multiplayer.get_remote_sender_id()
	if caller_id != driver_peer_id and caller_id != 0:  # 0 is local call
		print("❌ Unauthorized assign_driver call from: " + str(caller_id))
		return
	
	current_driver_peer_id = driver_peer_id
	print("Driver assigned!", current_driver_peer_id)
	
	# Call this on all clients so everyone knows who's driving
	sync_driver_assignment.rpc(driver_peer_id)


@rpc("authority", "call_local", "reliable")
func sync_driver_assignment(driver_peer_id: int):
	current_driver_peer_id = driver_peer_id
	print("Driver synced to all clients: " + str(driver_peer_id))
	
	# Only call enter_boat on the actual driver's client
	if multiplayer.get_unique_id() == driver_peer_id:
		var player = PlayerRegistry.get_player(driver_peer_id)
		if player:
			player.player_input.enter_boat(self)
			print("Player entered boat on their client: " + str(player.player_input.boat_ref))
		else:
			print("❌ Player not found in registry: " + str(driver_peer_id))


@rpc("any_peer", "call_local")
func set_drive_input(throttle_input: float, steering_input: float):
	if not multiplayer.is_server(): 
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	if sender_id != current_driver_peer_id:
		print("❌ Invalid sender - Expected: " + str(current_driver_peer_id) + ", Got: " + str(sender_id))
		return
	
	print("✅ Drive input accepted from: " + str(sender_id))
	throttle = throttle_input
	steering = steering_input


@rpc("any_peer", "call_local")
func clear_driver():
	if not multiplayer.is_server(): 
		return
	
	print("Clearing driver: " + str(current_driver_peer_id))
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
		var target_speed = throttle * max_speed
		current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	
	var forward = transform.basis.x
	var movement_force = forward * current_speed * mass
	
	var resistance_force = -linear_velocity * water_resistance
	apply_central_force(movement_force + resistance_force)
	
	if current_driver_peer_id != -1:
		var steering_effectiveness = abs(current_speed) / max_speed
		var torque_amount = steering * turn_speed * steering_effectiveness * mass
		apply_torque(Vector3.UP * torque_amount)
