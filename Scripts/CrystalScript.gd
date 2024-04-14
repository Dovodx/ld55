extends Node

func _on_body_entered(body):
	if body.name != "player": return
	body.get_crystal(get_node("."))
