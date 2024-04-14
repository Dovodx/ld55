extends Node

@export var enemy1: PackedScene

var levelNum = 0
var enemyCount = 0
#480x270
var screenCenter = Vector2(480, 270)
var boundsOffset = 50

var timesBetweenLevels = [10, 10, 15, 15, 15, 15]
var levelTimer: Timer

var player: Node2D

func _ready():
	player = get_node("/root/level/player")
	levelTimer = get_node("next level timer")
	enemyCount = 0
	next_level()
	levelTimer.wait_time = timesBetweenLevels[levelNum - 1]
	levelTimer.start()
	
func spawn_enemy():
	enemyCount += 1
	var enemyToSpawn = enemy1.instantiate()
	#todo ensure enemies spawn away from player and within level bounds
	enemyToSpawn.global_position = get_point_away_from_player()
	get_tree().get_root().get_node("level/enemies").add_child(enemyToSpawn)

func enemy_dead():
	#todo not sure if I'll need this, but an enemy cap isn't a bad idea
	enemyCount -= 1
	if enemyCount < 0:
		print("ERROR: Enemy count below 0?")

func next_level():
	levelNum += 1
	player.next_level()
	#todo more interesting waves, enemy variety
	for i in levelNum:
		call_deferred("spawn_enemy")

func respawn_crystals():
	var num = 0
	for crystal in get_node("/root/level/crystals").get_children():
		#todo randomize positions away from player
		crystal.visible = true
		crystal.set_deferred("monitoring", true)
		crystal.set_deferred("monitorable", true)
		crystal.global_position = get_point_away_from_player()
		num += 1

func get_point_away_from_player():
	var quadrant = Vector2.ONE
	if player.global_position.x < 960 / 2.0:
		quadrant.x = -1
	if player.global_position.y < 540 / 2.0:
		quadrant.y = -1
	
	var flipx = randi_range(0, 1)
	var flipy = randi_range(0, 1)
	if flipx == 0 and flipy == 0:
		flipx = 1
		flipy = 1
	var pos = quadrant
	if flipx:
		pos.x *= -1
	if flipy:
		pos.y *= -1
	
	var xroll = randf_range(0.15, 0.45)
	var yroll = randf_range(max(xroll, 0.3), 0.45)
	pos.x *= 960 * xroll
	pos.y *= 540 * yroll
	pos += screenCenter
	
	return pos

func _on_next_level_timer_timeout():
	next_level()
	#levelTimer.wait_time = timesBetweenLevels[min(levelNum - 1, timesBetweenLevels.size() - 1)]
	levelTimer.wait_time = 10
	levelTimer.start()
