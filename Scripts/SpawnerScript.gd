extends Node

@export var enemy1: PackedScene

var levelNum = 0
var enemyCount = 0
#480x270
var screenCenter = Vector2(240, 135)

var player: Node2D

func _ready():
	player = get_node("/root/level/player")
	enemyCount = 0
	next_level()
	
func spawn_enemy():
	enemyCount += 1
	var enemyToSpawn = enemy1.instantiate()
	var distanceFromCenter = randi_range(90, 120)
	var angle = randi_range(0, 360)
	var distanceVector = Vector2(distanceFromCenter, 0)
	distanceVector = distanceVector.rotated(deg_to_rad(angle))
	distanceVector.x *= 16.0 / 9.0
	enemyToSpawn.global_position = screenCenter + distanceVector
	get_tree().get_root().get_node("level/enemies").add_child(enemyToSpawn)

func enemy_dead():
	enemyCount -= 1
	if enemyCount == 0:
		next_level()
	elif enemyCount < 0:
		print("ERROR: Enemy count below 0?")

func next_level():
	levelNum += 1
	player.next_level()
	player.global_position = screenCenter
	for crystal in get_node("/root/level/crystals").get_children():
		crystal.visible = true
		crystal.set_deferred("monitoring", true)
		crystal.set_deferred("monitorable", true)
	
	#todo more interesting waves, enemy variety
	for i in levelNum:
		call_deferred("spawn_enemy")
