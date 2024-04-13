extends Node



func _on_body_entered(body):
	body.get_crystal(get_node("."))
