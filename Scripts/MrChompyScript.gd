extends CharacterBody2D

var speed = 500.0
var damage = 5.0

var sprite: Sprite2D
var spriteRoot: Node2D
var spritePositions = [Vector2.ZERO, Vector2.ZERO]
var lastPhysTime = Time.get_ticks_usec()

var hitbox: Area2D
var target: Node2D = null
var player: Node2D

func _ready():
	sprite = get_node("sprite root/sprite")
	spriteRoot = get_node("sprite root")
	spritePositions[0] = global_position
	spritePositions[1] = global_position
	
	hitbox = get_node("hitbox")
	player = get_node("/root/level/player")
	hitbox.area_entered.connect(_on_enemy_hit)

func _on_enemy_hit(area):
	#todo score
	if area.get_parent().get_parent().name == "enemies":
		area.get_parent().take_damage(damage)
		get_node("hit").play()
		
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
		get_node("attack cooldown").start()

func _on_attack_cooldown_timeout():
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)

func _process(delta):
	var timeDiff = (Time.get_ticks_usec() - lastPhysTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	spriteRoot.global_position = spritePositions[0].lerp(
		spritePositions[1], lerpWeight
	)

func _physics_process(delta):
	velocity *= 0.99
	sprite.flip_h = velocity.x < 0
	
	if is_on_wall():
		if get_wall_normal().x != 0:
			velocity.x *= -1
		if get_wall_normal().y != 0:
			velocity.y *= -1

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()

func _on_attack_timer_timeout():
	if target == null or target == player:
		find_new_target()
	var attackDir = Vector2.RIGHT
	if target != null:
		attackDir = global_position.direction_to(target.global_position)
	else:
		attackDir = global_position.direction_to(target.global_position).rotated(deg_to_rad(randi_range(-35, 35)))
	velocity = attackDir * speed

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
