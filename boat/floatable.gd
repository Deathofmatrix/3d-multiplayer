extends Node3D
class_name Floatable

@export_category("Dependencies")
@export var rigid_body: RigidBody3D

@export_category("Variables")
@export var float_force: float = 1.0
@export var water_drag: float = 0.05
@export var water_angular_drag: float = 0.05

var float_points: Array

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

const water_height = 0.0

func _ready() -> void:
	float_points = get_children()

func _physics_process(delta: float) -> void:
	var total_force = 0.0
	var submerged_count = 0
	
	for point in float_points:
		print("point g pos ", point.global_position)
		var depth = water_height - point.global_position.y
		if depth > 0:
			submerged_count += 1
			var force = float_force * gravity * depth * rigid_body.mass
			total_force += force
			rigid_body.apply_force(Vector3.UP * force, point.global_position - rigid_body.global_position)
	
	if submerged_count > 0:
		rigid_body.linear_velocity *= (1.0 - water_drag)
		rigid_body.angular_velocity *= (1.0 - water_angular_drag)
	
	
	print("Submerged points: ", submerged_count)
	print("Total upward force: ", total_force)
	print("Gravity force: ", rigid_body.mass * gravity)
	print("Object Y position: ", rigid_body.global_position.y)
