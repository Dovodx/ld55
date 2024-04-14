extends CharacterBody2D

var speed = 500.0
var hitSpeedThreshold = 0.5
var damage = 1.0
var stunTime = 0.5
var pushForce = 250.0

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
	hitbox.area_entered.connect(player._hit_enemy.bind(damage))
	hitbox.area_entered.connect(_on_enemy_hit)

func _on_enemy_hit(area):
	#todo probably okay to hit multiple enemies in one charge?
	#todo push enemy out of the way
	if area.get_parent().get_parent().name == "enemies":
		#hitbox.set_deferred("monitoring", false)
		#hitbox.set_deferred("monitorable", false)
		
		#todo probably have to stop enemy's movement timer to "stun" them
		area.get_parent().stun(stunTime)
		var awayFromPlayer = player.global_position.direction_to(area.get_parent().global_position)
		area.get_parent().velocity = awayFromPlayer * pushForce

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
	velocity *= 0.96
	sprite.flip_h = velocity.x < 0
	
	if velocity.length() < speed * hitSpeedThreshold:
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
	else:
		hitbox.set_deferred("monitoring", true)
		hitbox.set_deferred("monitorable", true)
	
	if is_on_wall():
		if get_wall_normal().x != 0:
			velocity.x *= -1
		if get_wall_normal().y != 0:
			velocity.y *= -1

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()

func _on_move_timer_timeout():
	if target == null or target == player:
		find_new_target()
	var attackDir = Vector2.RIGHT
	if target != null:
		attackDir = global_position.direction_to(target.global_position)
	else:
		attackDir = global_position.direction_to(target.global_position).rotated(deg_to_rad(randi_range(-35, 35)))
	var fixedAngle = roundi(rad_to_deg(attackDir.angle()) / 90.0) * 90
	attackDir = attackDir.rotated(-attackDir.angle() + deg_to_rad(fixedAngle))
	velocity = attackDir * speed

func find_new_target():
	#search for the nearest enemy, EAT
	var lowestDistance = 999999999999
	var newTarget: Node2D
	for enemy in get_node("/root/level/enemies").get_children():
		if enemy.dead:
			continue
		var distance = global_position.distance_squared_to(enemy.global_position)
		if distance < lowestDistance:
			lowestDistance = distance
			newTarget = enemy
	if newTarget != null:
		target = newTarget
	else:
		target = player
