extends CharacterBody3D
class_name Player

@export var move_speed := 8.0
@export var attack_impulse := 10.0
@export var acceleration := 6.0
@export var jump_initial_impulse := 12.0
@export var jump_additional_force := 4.5
@export var rotation_speed := 12.0
@export var stopping_speed := 1.0
@export var sync_delta_max := 1.0

## Sync properties
@export var _position: Vector3
@export var _velocity: Vector3
@export var _direction: Vector3 = Vector3.ZERO
@export var _strong_direction: Vector3 = Vector3.FORWARD

var position_before_sync: Vector3

var last_sync_time_ms: int
var sync_delta: float

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
