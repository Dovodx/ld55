extends CharacterBody2D

const SPEED = 200.0

var maxHealth = 100
var health = 100
var invulnerable = false
var invulnTimer: Timer

var sprite: Sprite2D
var spritePositions = [Vector2.ZERO, Vector2.ZERO]
var lastPhysTime = Time.get_ticks_usec()

var anim: AnimationPlayer

var healthBar: ColorRect

func _ready():
	health = maxHealth
	healthBar = get_node("/root/level/Control/health fill")
	invulnTimer = get_node("invuln timer")
	
	sprite = get_node("sprite")
	spritePositions[0] = sprite.global_position
	spritePositions[1] = sprite.global_position
	anim = get_node("AnimationPlayer")
	anim.play("stand")

func _process(delta):
	var timeDiff = (Time.get_ticks_usec() - lastPhysTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	sprite.global_position = spritePositions[0].lerp(
		spritePositions[1], lerpWeight
	)

func _physics_process(delta):
	var movementVector = Vector2.ZERO
	var dirH = Input.get_axis("left", "right")
	if dirH:
		movementVector.x = dirH * SPEED
	else:
		movementVector.x = dirH * -SPEED
	sprite.flip_h = sprite.flip_h if dirH == 0 else dirH < 0
	
	var dirV = Input.get_axis("up", "down")
	if dirV:
		movementVector.y = dirV * SPEED
	else:
		movementVector.y = dirV * -SPEED
	
	velocity = movementVector.limit_length(SPEED)

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()

func get_crystal(crystal):
	crystal.visible = false
	#todo play sound


func _on_hitbox_body_entered(body):
	take_damage(10)

func take_damage(dmg):
	invulnerable = true
	invulnTimer.start()
	health -= dmg
	healthBar.size.x = max((health as float / maxHealth) * 180.0, 0)
	#todo death, hurt anim


func _on_invuln_timer_timeout():
	#todo invuln effect
	invulnerable = false
