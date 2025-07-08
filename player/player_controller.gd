extends Node
class_name PlayerController

@export var move_speed := 8.0
@export var acceleration := 6.0
@export var jump_impulse := 12.0
@export var gravity := -30.0
@export var stopping_speed := 1.0
@export var rotation_speed := 12.0
@export var interpolation_speed := 10.0

var move_direction = Vector3.ZERO
var last_strong_direction = Vector3.FORWARD
var velocity = Vector3.ZERO
var jump_requested = false

var player: Player

func setup(player_body: Player):
	player = player_body


func _physics_process(delta: float) -> void:
	if player.is_multiplayer_authority():
		_move_player_authoritative(delta)
	else:
		_interpolate_player_remote(delta)


func _move_player_authoritative(delta):
	var y_velocity = player.velocity.y
	player.velocity.y = 0.0
	player.velocity = player.velocity.lerp(move_direction * move_speed, acceleration * delta)
	
	if move_direction.length() == 0 and player.velocity.length() < stopping_speed:
		player.velocity = Vector3.ZERO
	player.velocity.y = y_velocity + gravity * delta
	
	if jump_requested and player.is_on_floor():
		player.velocity.y += jump_impulse
		jump_requested = false
	
	player.move_and_slide()
	
	if move_direction.length() > 0.2:
		last_strong_direction = move_direction.normalized()
		_orient_character(last_strong_direction, delta)
	
	player._position = player.global_position
	player._velocity = player.velocity
	player._direction = move_direction


func _interpolate_player_remote(delta):
	# Smoothly interpolate remote player
	player.global_position = player.global_position.lerp(player._position, delta * interpolation_speed)
	player.velocity = player._velocity

	if player._direction.length() > 0.1:
		_orient_character(player._direction.normalized(), delta)


func _orient_character(direction, delta):
	var rotation_root = player._rotation_root
	var left_axis = Vector3.UP.cross(direction)
	var target_basis = Basis(left_axis, Vector3.UP, direction).get_rotation_quaternion()
	var current_basis = rotation_root.transform.basis.get_rotation_quaternion()
	rotation_root.transform.basis = Basis(current_basis.slerp(target_basis, delta * rotation_speed))
