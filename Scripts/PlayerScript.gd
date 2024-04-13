extends CharacterBody2D

const SPEED = 200.0
@export var currentSpeed = SPEED

var maxHealth = 100
var health = 100
var invulnerable = false
var invulnTimer: Timer

var crystalsCollected = 0
var summonActive = false
var canPickup = true
var levelResetTimer: Timer

var spriteRoot: Node2D
var spritePositions = [Vector2.ZERO, Vector2.ZERO]
var charSprite: Sprite2D
var summonSprite: Sprite2D
var lastPhysTime = Time.get_ticks_usec()

var anim: AnimationPlayer

var healthBar: ColorRect

func _ready():
	currentSpeed = SPEED
	health = maxHealth
	healthBar = get_node("/root/level/Control/health fill")
	invulnTimer = get_node("invuln timer")
	levelResetTimer = get_node("level reset")
	
	spriteRoot = get_node("sprite root")
	spritePositions[0] = spriteRoot.global_position
	spritePositions[1] = spriteRoot.global_position
	charSprite = get_node("sprite root/sprite")
	summonSprite = get_node("sprite root/summon sprite")
	anim = get_node("AnimationPlayer")
	anim.play("stand")

func next_level():
	summonActive = false
	invulnerable = false
	canPickup = false
	levelResetTimer.start()

func _process(delta):
	var timeDiff = (Time.get_ticks_usec() - lastPhysTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	spriteRoot.global_position = spritePositions[0].lerp(
		spritePositions[1], lerpWeight
	)

func _physics_process(delta):
	var movementVector = Vector2.ZERO
	var dirH = Input.get_axis("left", "right")
	if dirH:
		movementVector.x = dirH * currentSpeed
	else:
		movementVector.x = dirH * -currentSpeed
	charSprite.flip_h = charSprite.flip_h if dirH == 0 else dirH < 0
	summonSprite.flip_h = summonSprite.flip_h if dirH == 0 else dirH < 0
	
	var dirV = Input.get_axis("up", "down")
	if dirV:
		movementVector.y = dirV * currentSpeed
	else:
		movementVector.y = dirV * -currentSpeed
	
	velocity = movementVector.limit_length(currentSpeed)
	if !summonActive:
		if movementVector.length() == 0:
			anim.play("stand")
		else:
			anim.play("run")

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()

func get_crystal(crystal):
	if !canPickup: return
	crystal.visible = false
	crystal.set_deferred("monitoring", false)
	crystal.set_deferred("monitorable", false)
	crystalsCollected += 1
	get_node("sounds/pickup").play()
	if !summonActive and crystalsCollected == 4:
		summon()
		crystalsCollected = 0

func summon():
	summonActive = true
	canPickup = false
	invulnTimer.stop()
	invulnerable = true
	anim.play("summon")
	anim.queue("summon_run")
	#todo end state when all enemies gone

func _take_damage(body, dmg):
	if invulnerable: return
	get_node("sounds/hurt").play()
	invulnerable = true
	invulnTimer.start()
	health -= dmg
	healthBar.size.x = max((health as float / maxHealth) * 180.0, 0)
	#todo death, hurt anim

func _on_invuln_timer_timeout():
	#todo invuln effect
	print("invuln timer expired")
	invulnerable = false

func _on_enemy_hit(area):
	#todo score
	if area.get_parent().get_parent().name == "enemies":
		area.get_parent().die()

func _on_level_reset_timeout():
	canPickup = true
