extends Node
class_name Floatable

@export_category("Dependencies")
@export var rigid_body: RigidBody3D

@export_category("Variables")
@export var float_force: float = 1.0
@export var water_drag: float = 0.05
@export var water_angular_drag: float = 0.05

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

const water_height = 0.0


func _physics_process(delta: float) -> void:
	var depth = water_height - rigid_body.global_position.y
	if depth > 0:
		rigid_body.apply_central_force(Vector3.UP * float_force * gravity * depth * rigid_body.mass)
