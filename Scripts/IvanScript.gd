extends CharacterBody2D

var speed = 350.0
var currentSpeed = speed
var damage = 15.0

var sprite: Sprite2D
var spriteRoot: Node2D
var spritePositions = [Vector2.ZERO, Vector2.ZERO]
var lastPhysTime = Time.get_ticks_usec()

var hitbox: Area2D
var target: Node2D = null
var savedTargetPos = Vector2.ZERO
var player: Node2D

var moveTimer: Timer
var attackTimer: Timer
var fireTimer: Timer
var cooldownTimer: Timer

var anim: AnimationPlayer

func _ready():
	currentSpeed = speed
	sprite = get_node("sprite root/sprite")
	spriteRoot = get_node("sprite root")
	spritePositions[0] = global_position
	spritePositions[1] = global_position
	
	hitbox = get_node("hitbox")
	player = get_node("/root/level/player")
	
	moveTimer = get_node("move timer")
	attackTimer = get_node("attack timer")
	fireTimer = get_node("fire timer")
	cooldownTimer = get_node("attack cooldown")
	anim = get_node("AnimationPlayer")
	
	hitbox.area_entered.connect(_on_enemy_hit)
	anim.play("float")

func _on_enemy_hit(area):
	#todo allow for multiple hits probably
	if area.get_parent().get_parent().name == "enemies":
		area.get_parent().take_damage(damage)

func _process(delta):
	var timeDiff = (Time.get_ticks_usec() - lastPhysTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	spriteRoot.global_position = spritePositions[0].lerp(
		spritePositions[1], lerpWeight
	)

func _physics_process(delta):
	velocity *= 0.96
	sprite.flip_h = velocity.x < 0

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()

func _on_move_timer_timeout():
	#Move towards player
	var moveDir = global_position.direction_to(player.global_position).rotated(deg_to_rad(randi_range(-35, 35)))
	velocity = moveDir * speed
	anim.play("float")

func _on_attack_timer_timeout():
	if target == null or target == player:
		find_new_target()
	if target == null or target == player:
		attackTimer.start()
		return
	currentSpeed = 0
	moveTimer.stop()
	velocity = Vector2.ZERO
	
	savedTargetPos = target.global_position
	anim.play("charge")
	anim.queue("fire")

func _on_animation_player_current_animation_changed(animName):
	if animName == "fire":
		if target != null:
			hitbox.rotation = (target.global_position - hitbox.global_position).angle()
		else:
			hitbox.rotation = (savedTargetPos - hitbox.global_position).angle()
		#Set to active in animation
		hitbox.visible = true
		fireTimer.start()

func _on_fire_timer_timeout():
	cooldownTimer.start()
	hitbox.visible = false
	#Anim also sets active, this is a "double check" (dead code)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

func _on_attack_cooldown_timeout():
	currentSpeed = speed
	attackTimer.start()
	moveTimer.start()

func find_new_target():
	#search for the nearest enemy, LASE
	var lowestDistance = 999999999999
	var newTarget: Node2D
	for enemy in get_node("/root/level/enemies").get_children():
		if enemy.dead or !enemy.get_node("sprite root").visible:
			continue
		#try it out - target enemy closest to player, might be OP
		var distance = player.global_position.distance_squared_to(enemy.global_position)
		if distance < lowestDistance:
			lowestDistance = distance
			newTarget = enemy
	if newTarget != null:
		target = newTarget
	else:
		target = player
