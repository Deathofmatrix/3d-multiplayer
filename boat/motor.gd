extends Area3D

func interact(interacting_player: Player):
	print("interacting")
	$".."._on_motor_on_interact(interacting_player)
