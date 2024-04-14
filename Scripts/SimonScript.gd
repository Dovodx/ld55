extends CharacterBody2D

var moveSpeed = 300.0
var lungeSpeed = 600.0
var damage = 0.5

var sprite: Sprite2D
var spriteRoot: Node2D
var spritePositions = [Vector2.ZERO, Vector2.ZERO]
var lastPhysTime = Time.get_ticks_usec()

var hitbox: Area2D
var target: Node2D = null

var capturedEnemy: Node2D = null
var capturedMaxHealth = 10.0 #placeholder numbers - these are set to the enemy victim's health
var capturedHealth = 10.0

var player: Node2D
var biteTimer: Timer
var lungeTimer: Timer

var anim: AnimationPlayer

func _ready():
	sprite = get_node("sprite root/sprite")
	spriteRoot = get_node("sprite root")
	spritePositions[0] = global_position
	spritePositions[1] = global_position
	
	biteTimer = get_node("bite timer")
	lungeTimer = get_node("lunge timer")
	anim = get_node("AnimationPlayer")
	hitbox = get_node("hitbox")
	player = get_node("/root/level/player")
	hitbox.area_entered.connect(player._hit_enemy.bind(damage))
	hitbox.area_entered.connect(_on_enemy_hit)
	
	#hitbox only active during "open" animation, when he lunges at an enemy to eat them
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	
	anim.play("move")

func _on_enemy_hit(area):
	#todo grab and hold enemy, not sure if enemy should be considered dead or have a limit to how much hp can be sapped
	#heal player while munching on enemy
	if capturedEnemy == null:
		biteTimer.stop()
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
		capturedEnemy = area.get_parent()
		capturedEnemy.get_node("sprite root/sprite").visible = false
		capturedEnemy.get_node("hitbox").set_deferred("monitoring", false)
		capturedEnemy.get_node("hitbox").set_deferred("monitorable", false)
		capturedEnemy.get_node("hurtbox").set_deferred("monitoring", false)
		capturedEnemy.get_node("hurtbox").set_deferred("monitorable", false)
		capturedEnemy.stun(stunTime)
		capturedEnemy.velocity = Vector2.ZERO
		velocity = Vector2.ZERO
		anim.play("munch")

func drain_health():
	if capturedEnemy == null or capturedEnemy.dead or capturedEnemy.health <= 0:
		anim.play("move")
		capturedEnemy = null
		find_new_target()
		lungeTimer.start()
		var moveDir = global_position.direction_to(target.global_position).rotated(deg_to_rad(randi_range(-80, 80)))
		velocity = moveDir * moveSpeed
	else:
		capturedEnemy.take_damage(damage)
		player.heal(damage)
		
func _on_bite_timer_timeout():
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	anim.play("move")
	lungeTimer.start()

func _process(delta):
	var timeDiff = (Time.get_ticks_usec() - lastPhysTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	spriteRoot.global_position = spritePositions[0].lerp(
		spritePositions[1], lerpWeight
	)

func _physics_process(delta):
	velocity *= 0.99 if target != player else 1.0
	sprite.flip_h = velocity.x < 0

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()

func _on_lunge_timer_timeout():
	if target == null or target == player:
		find_new_target()
	var attackDir = Vector2.RIGHT
	if target != null:
		attackDir = global_position.direction_to(target.global_position)
		velocity = attackDir * lungeSpeed
		anim.play("open")
		hitbox.set_deferred("monitoring", true)
		hitbox.set_deferred("monitorable", true)
		biteTimer.start()
	else:
		attackDir = global_position.direction_to(target.global_position).rotated(deg_to_rad(randi_range(-80, 80)))
		velocity = attackDir * moveSpeed
		lungeTimer.start()

func find_new_target():
	#search for the nearest enemy, EAT
	var lowestDistance = 999999999999
	var newTarget: Node2D
	for enemy in get_node("/root/level/enemies").get_children():
		if enemy.dead or !enemy.get_node("sprite root").visible:
			continue
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < lowestDistance:
			lowestDistance = distance
			newTarget = enemy
	if newTarget != null:
		target = newTarget
	else:
		target = player
