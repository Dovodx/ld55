extends CharacterBody2D

var speed = 650.0

var sprite: Sprite2D
var spriteRoot: Node2D
var spritePositions = [Vector2.ZERO, Vector2.ZERO]
var lastPhysTime = Time.get_ticks_usec()

var hitbox: Area2D

func _ready():
	sprite = get_node("sprite root/sprite")
	sprite = get_node("sprite root")
	spritePositions[0] = global_position
	spritePositions[1] = global_position

func _physics_process(delta):
	velocity *= 0.98
	sprite.flip_h = velocity.x > 0

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()


func _on_attack_timer_timeout():
	#search for the nearest enemy, EAT
	var lowestDistance = 999999999999
	for enemy in get_node("/root/level/enemies").get_children():
		if enemy.dead:
			print("skipping dead enemy")
			continue
		
