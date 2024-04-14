extends Node2D

var pushbackForce = 500.0
var pushbackStunTime = 1.0

func _on_summon_pushback_area_entered(area):
	if area.get_parent().get_parent().name == "enemies":
		area.get_parent().stun(pushbackStunTime)
		var awayFromPlayer = get_node("/root/level/player").global_position.direction_to(area.get_parent().global_position)
		area.get_parent().velocity = awayFromPlayer * pushbackForce
