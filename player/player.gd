extends CharacterBody3D
class_name Player

## Sync properties
@export var _position: Vector3
@export var _velocity: Vector3
@export var _direction: Vector3 = Vector3.ZERO
@export var _strong_direction: Vector3 = Vector3.FORWARD

#@onready var _ground_shapecast: ShapeCast3D = $GroundShapeCast
#@onready var _character_skin: CharacterSkin = $CharacterRotationRoot/CharacterSkin
@onready var _rotation_root: Node3D = $CharacterRotationRoot
@onready var _camera_controller: CameraController = $CameraController
@onready var _synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var player_input: PlayerInput = $PlayerInput
@onready var player_controller: PlayerController = $PlayerController

var move_direction: Vector3 = Vector3.ZERO
var jump_requested : bool = false

func _ready() -> void:
	PlayerRegistry.register_player(get_multiplayer_authority(), self)
	
	if is_multiplayer_authority():
		player_input.set_process(true)
		_camera_controller.setup(self)
	else:
		player_input.set_process(false)
		_synchronizer.delta_synchronized.connect(_on_sync)
		_synchronizer.synchronized.connect(_on_sync)
	player_controller.setup(self)


func _on_sync() -> void:
	velocity = _velocity

func _exit_tree() -> void:
	PlayerRegistry.unregister_player(get_multiplayer_authority())

#
#
#func _ready() -> void:
	#if is_multiplayer_authority():
		#_camera_controller.setup(self)
	#else:
		#rotation_speed /= 1.5
		#_synchronizer.delta_synchronized.connect(on_synchronized)
		#_synchronizer.synchronized.connect(on_synchronized)
		#on_synchronized()
#
#
#func _process(delta: float) -> void:
	#if is_steering_boat: return
	#if interact_ray_cast.is_colliding():
		#var collider: Object = interact_ray_cast.get_collider()
		#if collider is not Node: return
		#if not collider.is_in_group("interactable"): return
		#print(collider.name)
		#current_interactable = collider
		#if collider.has_method("interact"):
			#print("hasmethod")
			#if Input.is_action_just_pressed("interact"):
				#collider.interact(self)
		#else:
			#pass
			##pick up item
	#else:
		#current_interactable = null
#
#
#func _input(event: InputEvent) -> void:
	#if is_steering_boat and event.is_action_pressed("interact"):
		#is_steering_boat = false
#
#
#func _physics_process(delta: float) -> void:
	#if not is_multiplayer_authority(): interpolate_client(delta); return
	#
	## Get input and movement state
	#var is_just_jumping := Input.is_action_just_pressed("jump") and is_on_floor()
	#var is_air_boosting := Input.is_action_pressed("jump") and not is_on_floor() and velocity.y > 0.0
	#
	#_move_direction = _get_camera_oriented_input()
	#
	#if _move_direction.length() > 0.2:
		#_last_strong_direction = _move_direction.normalized()
	#
	#_orient_character_to_direction(_last_strong_direction, delta)
	#
	#var y_velocity := velocity.y
	#velocity.y = 0.0
	#velocity = velocity.lerp(_move_direction * move_speed, acceleration * delta)
	#if _move_direction.length() == 0 and velocity.length() < stopping_speed:
		#velocity = Vector3.ZERO
	#velocity.y = y_velocity
	#
	## Update position
	#
	#velocity.y += _gravity * delta
	#
	#if is_just_jumping:
		#velocity.y += jump_initial_impulse
	#elif is_air_boosting:
		#velocity.y += jump_additional_force * delta
	#
	### Set character animation
	##if is_just_jumping:
		##_character_skin.jump.rpc()
	##elif not is_on_floor() and velocity.y < 0:
		##_character_skin.fall.rpc()
	##elif is_on_floor():
		##var xz_velocity := Vector3(velocity.x, 0, velocity.z)
		##if xz_velocity.length() > stopping_speed:
			##_character_skin.set_moving.rpc(true)
			##_character_skin.set_moving_speed.rpc(inverse_lerp(0.0, move_speed, xz_velocity.length()))
		##else:
			##_character_skin.set_moving.rpc(false)
	#
	#var position_before := global_position
	#move_and_slide()
	#var position_after := global_position
	#
	## If velocity is not 0 but the difference of positions after move_and_slide is,
	## character might be stuck somewhere!
	#var delta_position := position_after - position_before
	#var epsilon := 0.001
	#if delta_position.length() < epsilon and velocity.length() > epsilon:
		#global_position += get_wall_normal() * 0.1
	#
	#set_sync_properties()
#
#
#func steer_boat(pos :Vector3):
	#is_steering_boat = true
	#position = pos
	#
#
#
#func set_sync_properties() -> void:
	#_position = position
	#_velocity = velocity
	#_direction = _move_direction
	#_strong_direction = _last_strong_direction
#
#
#func on_synchronized() -> void:
	#velocity = _velocity
	#position_before_sync = position
	#
	#var sync_time_ms = Time.get_ticks_msec()
	#sync_delta = clampf(float(sync_time_ms - last_sync_time_ms) / 1000, 0, sync_delta_max)
	#last_sync_time_ms = sync_time_ms
#
#
#func interpolate_client(delta: float) -> void:
	#_orient_character_to_direction(_strong_direction, delta)
	#
	#if _direction.length() == 0:
		## Don't interpolate to avoid small jitter when stopping
		#if (_position - position).length() > 1.0 and _velocity.is_zero_approx():
			#position = _position # Fix misplacement
	#else:
		## Interpolate between position_before_sync and _position
		## and add to ongoing movement to compensate misplacement
		#var t = 1.0 if is_zero_approx(sync_delta) else delta / sync_delta
		#sync_delta = clampf(sync_delta - delta, 0, sync_delta_max)
		#
		#var less_misplacement = position_before_sync.move_toward(_position, t)
		#position += less_misplacement - position_before_sync
		#position_before_sync = less_misplacement
	#
	#velocity.y += _gravity * delta
	#move_and_slide()
#
#
#func _get_camera_oriented_input() -> Vector3:
	#if is_steering_boat: return Vector3.ZERO
	#var raw_input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	#
	#var input := Vector3.ZERO
	## This is to ensure that diagonal input isn't stronger than axis aligned input
	#input.x = raw_input.x * sqrt(1.0 - raw_input.y * raw_input.y / 2.0)
	#input.z = raw_input.y * sqrt(1.0 - raw_input.x * raw_input.x / 2.0)
	#
	#input = _camera_controller.transform.basis * input
	#input.y = 0.0
	#return input
#
#
#func _orient_character_to_direction(direction: Vector3, delta: float) -> void:
	#var left_axis := Vector3.UP.cross(direction)
	#var rotation_basis := Basis(left_axis, Vector3.UP, direction).get_rotation_quaternion()
	#var model_scale := _rotation_root.transform.basis.get_scale()
	#_rotation_root.transform.basis = Basis(_rotation_root.transform.basis.get_rotation_quaternion().slerp(rotation_basis, delta * rotation_speed)).scaled(
		#model_scale
	#)
#
#
#@rpc("any_peer", "call_remote", "reliable")
#func respawn(spawn_position: Vector3) -> void:
	#global_position = spawn_position
	#velocity = Vector3.ZERO
