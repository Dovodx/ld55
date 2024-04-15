extends Node

#Game stats
var enemiesSlain = 0
#var damageDealt = 0.0
var crystalsCollected = 0
var totalHealing = 0.0

var summonCounts = [0,0,0,0,0]

func reset_stats():
	enemiesSlain = 0
	crystalsCollected = 0
	totalHealing = 0.0
	summonCounts = [0,0,0,0,0]

func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
