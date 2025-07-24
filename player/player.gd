class_name Player
extends CharacterBody3D

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
