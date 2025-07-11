extends Node

var players_by_peer_id: Dictionary

func register_player(peer_id: int, player_node: Player):
	players_by_peer_id[peer_id] = player_node


func get_player(peer_id: int) -> Player:
	return players_by_peer_id.get(peer_id)


func unregister_player(peer_id: int):
	players_by_peer_id.erase(peer_id)
