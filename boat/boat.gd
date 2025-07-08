extends RigidBody3D
class_name Boat

var current_player: Player = null

func _on_motor_on_interact(interacting_player: Player) -> void:
	if current_player != null: return
	current_player = interacting_player
	current_player.steer_boat($Motor.position)
	print("interacedx")
