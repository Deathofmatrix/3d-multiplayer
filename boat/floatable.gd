class_name Floatable
extends Node3D

@export_category("Dependencies")
@export var rigid_body: RigidBody3D

@export_category("Variables")
@export var float_force: float = 1.0
@export var water_drag: float = 0.95
@export var water_angular_drag: float = 0.5

var float_points: Array

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

const water_height = 0.0

func _ready() -> void:
	float_points = get_children()

func _physics_process(delta: float) -> void:
	var total_force = 0.0
	var submerged_count = 0
	
	for point in float_points:
		#print("point g pos ", point.global_position)
		#var depth = water_height - point.global_position.y
		var height = point.global_position.y
		if height < water_height:
			submerged_count += 1
			
			var buoyancy = clamp((water_height - height) * rigid_body.mass / 1, 0, 1 * rigid_body.mass)
			
			rigid_body.apply_force(Vector3(0, gravity * buoyancy, 0), point.global_position - rigid_body.position)
			rigid_body.apply_central_force(buoyancy * -rigid_body.linear_velocity * water_drag)
			rigid_body.apply_torque(buoyancy * -rigid_body.angular_velocity * water_angular_drag)
	
	#print("Submerged points: ", submerged_count)
	#print("Total upward force: ", total_force)
	#print("Gravity force: ", rigid_body.mass * gravity)
	#print("Object Y position: ", rigid_body.global_position.y)
