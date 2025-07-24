class_name OrientationComponent
extends PackageComponent

@export var max_tilt_angle: float = 30.0
@export var shatter_delay: float = 2.0

var is_tilted: bool = false
var tilt_timer: float = 0.0

func _process(delta):
	if not is_active:
		return
	
	check_orientation(delta)


func check_orientation(delta):
	var up_vector = package_node.global_transform.basis.y
	var world_up = Vector3.UP
	var angle = rad_to_deg(up_vector.angle_to(world_up))
	
	if angle > max_tilt_angle:
		if not is_tilted:
			is_tilted = true
			package_warning.emit("Package is tilted! Keep it upright!")
		
		tilt_timer += delta
		if tilt_timer >= shatter_delay:
			package_failed.emit("Package shattered from being tilted!")
			# Add shatter effect here
			break_package()
	else:
		is_tilted = false
		tilt_timer = 0.0


func break_package():
	# Create shatter effect
	var pieces = create_shatter_pieces()
	for piece in pieces:
		add_physics_to_piece(piece)
	
	package_node.queue_free()

func create_shatter_pieces():
	# Placeholder for shatter effect
	var pieces = []
	for i in range(5):
		var piece = MeshInstance3D.new()
		piece.mesh = SphereMesh.new()
		piece.mesh.radius = 0.1
		piece.global_position = package_node.global_position + Vector3.ZERO.bounce(Vector3.ONE) * 0.5
		get_tree().current_scene.add_child(piece)
		pieces.append(piece)
	return pieces


func add_physics_to_piece(piece):
	var rb = RigidBody3D.new()
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.1
	collision.shape = shape
	
	rb.add_child(collision)
	piece.add_child(rb)
	rb.apply_central_impulse(Vector3(randf_range(-5, 5), randf_range(2, 8), randf_range(-5, 5)))
