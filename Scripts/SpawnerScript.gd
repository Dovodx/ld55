extends Node

@export var enemies: Array[PackedScene]

var levelNum = 0
var enemyCount = 0

#480x270
var screenCenter = Vector2(480, 270)
var boundsOffset = 50

var levelTimer: Timer

var player: Node2D

func _ready():
	player = get_node("/root/level/player")
	levelTimer = get_node("next level timer")
	enemyCount = 0
	next_level()
	levelTimer.wait_time = 10
	levelTimer.start()
	
func spawn_enemy():
	enemyCount += 1
	var highestEnemyNum = clamp(levelNum / 4, 0, enemies.size() - 1)
	var enemyNum = randi_range(0, highestEnemyNum)
	var enemyToSpawn = enemies[enemyNum].instantiate()
	enemyToSpawn.global_position = get_point_away_from_player()
	get_tree().get_root().get_node("level/enemies").add_child(enemyToSpawn)

func enemy_dead():
	enemyCount -= 1
	Global.enemiesSlain += 1
	if enemyCount < 0:
		print("ERROR: Enemy count below 0?")

func next_level():
	levelNum += 1
	player.next_level()
	print("level " + str(levelNum))
	for i in levelNum:
		call_deferred("spawn_enemy")

func stop_spawning():
	levelTimer.stop()

func respawn_crystals():
	if get_node("/root/level/crystals").get_children().size() < 10 and (Global.crystalsCollected) / 30 > get_node("/root/level/crystals").get_children().size():
		var newCrystal = get_node("/root/level/crystals").get_children()[0].duplicate()
		get_node("/root/level/crystals").call_deferred("add_child", newCrystal)
		
	for crystal in get_node("/root/level/crystals").get_children():
		crystal.visible = true
		crystal.set_deferred("monitoring", true)
		crystal.set_deferred("monitorable", true)
		crystal.global_position = get_point_away_from_player()

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
	pos = pos.clamp(Vector2(boundsOffset, boundsOffset), Vector2(960 - boundsOffset, 540 - 28 - boundsOffset))
	
	return pos

func _on_next_level_timer_timeout():
	next_level()
	levelTimer.wait_time = 10
	levelTimer.start()
