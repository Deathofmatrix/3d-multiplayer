extends Node3D
class_name CameraController

@export_node_path var player_path : NodePath
@export var invert_mouse_y := false
@export_range(0.0, 1.0) var mouse_sensitivity := 0.25
@export_range(0.0, 8.0) var joystick_sensitivity := 2.0
@export var tilt_upper_limit := deg_to_rad(80.0)
@export var tilt_lower_limit := deg_to_rad(-80.0)

@onready var camera: Camera3D = $PlayerCamera
@onready var interact_ray_cast: RayCast3D = $PlayerCamera/InteractRayCast

var _rotation_input: float
var _tilt_input: float
var _mouse_input := false
var _offset: Vector3
var _anchor: CharacterBody3D
var _euler_rotation: Vector3


func _ready() -> void:
	if not is_multiplayer_authority():
		set_process_input(false)
		set_physics_process(false)


func _unhandled_input(event: InputEvent) -> void:
	_mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if _mouse_input:
		_rotation_input = -event.relative.x * mouse_sensitivity
		_tilt_input = -event.relative.y * mouse_sensitivity


func _physics_process(delta: float) -> void:
	if not _anchor: return
	
	_rotation_input += Input.get_action_raw_strength("camera_left") - Input.get_action_raw_strength("camera_right")
	_tilt_input += Input.get_action_raw_strength("camera_up") - Input.get_action_raw_strength("camera_down")
	
	if invert_mouse_y:
		_tilt_input *= -1
	
	_euler_rotation.y += _rotation_input * delta
	rotation.y = _euler_rotation.y
	
	_euler_rotation.x += _tilt_input * delta
	_euler_rotation.x = clamp(_euler_rotation.x, tilt_lower_limit, tilt_upper_limit)
	camera.rotation.x = _euler_rotation.x
	
	camera.rotation.z = 0
	
	_rotation_input = 0.0
	_tilt_input = 0.0


func setup(anchor: CharacterBody3D) -> void:
	_anchor = anchor
	_offset = global_transform.origin - anchor.global_transform.origin


func get_interact_ray() -> RayCast3D:
	return interact_ray_cast
