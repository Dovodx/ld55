extends CharacterBody2D

var speed = 100.0
var slowFactor = 0.18 #Limit enemies inside to thier top speed multiplied by this

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
	#hitbox.area_entered.connect(_on_enemy_hit)

func _on_enemy_hit(area):
	if area.get_parent().get_parent().name == "enemies":
		var enemy = area.get_parent()
		enemy.velocity = enemy.velocity.limit_length(enemy.SPEED * slowFactor)

func _on_slow_timer_timeout():
	for area in hitbox.get_overlapping_areas():
		_on_enemy_hit(area)

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

func _on_move_timer_timeout():
	var attackDir = Vector2.RIGHT
	velocity = attackDir.rotated(deg_to_rad(randf_range(0, 360))) * speed
