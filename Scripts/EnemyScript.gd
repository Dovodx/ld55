extends CharacterBody2D


const SPEED = 200.0
var movementTimer: Timer
var player: Node2D

var sprite: Sprite2D
var spritePositions = [Vector2.ZERO, Vector2.ZERO]
var lastPhysTime = Time.get_ticks_usec()

func _ready():
	movementTimer = get_node("movement timer")
	movementTimer.start()
	player = get_node("/root/level/player")
	
	sprite = get_node("sprite")
	spritePositions[0] = sprite.global_position
	spritePositions[1] = sprite.global_position

func _process(delta):
	var timeDiff = (Time.get_ticks_usec() - lastPhysTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	sprite.global_position = spritePositions[0].lerp(
		spritePositions[1], lerpWeight
	)

func _physics_process(delta):
	var movementVector = Vector2.ZERO
	#todo where to move
	velocity *= 0.98

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()


func _on_movement_timer_timeout():
	velocity = (player.global_position - global_position).normalized() * SPEED
