extends CharacterBody2D


const SPEED = 550.0
var dmgAmount = 10
var angleVariationDeg = 30
var movementTimer: Timer
var player: Node2D
var dead = false

var sprite: Sprite2D
var scaredSprite = load("res://Sprites/enemy1/enemy1 scared.png")
var spritePositions = [Vector2.ZERO, Vector2.ZERO]
var lastPhysTime = Time.get_ticks_usec()

var hitbox: Area2D
var hurtbox: Area2D

signal take_damage(dmg)

func _ready():
	dead = false
	movementTimer = get_node("movement timer")
	movementTimer.start()
	player = get_node("/root/level/player")
	
	sprite = get_node("sprite")
	spritePositions[0] = sprite.global_position
	spritePositions[1] = sprite.global_position
	
	hitbox = get_node("hitbox")
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	hurtbox = get_node("hurtbox")
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	visible = true
	
	hitbox.body_entered.connect(Callable(player._take_damage.bind(dmgAmount)))

func _process(delta):
	var timeDiff = (Time.get_ticks_usec() - lastPhysTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	sprite.global_position = spritePositions[0].lerp(
		spritePositions[1], lerpWeight
	)

func _physics_process(delta):
	if !dead:
		velocity *= 0.98
		sprite.flip_h = velocity.x > 0
	else:
		velocity = Vector2.ZERO
	
	if player.summonActive:
		sprite.texture = scaredSprite

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()

func _on_movement_timer_timeout():
	var fleeDir = -0.7 if player.summonActive else 1.0
	var fleeAngle = 5.0 if player.summonActive else 1.0
	velocity = (player.global_position - global_position).normalized().rotated(deg_to_rad(randi_range(-angleVariationDeg, angleVariationDeg) * fleeAngle / 2.0)) * SPEED * fleeDir

func die():
	if dead: return
	get_node("/root/level/spawner").enemy_dead()
	dead = true
	call_deferred("queue_free")
	#hitbox.set_deferred("monitoring", false)
	#hitbox.set_deferred("monitorable", false)
	#hurtbox.set_deferred("monitoring", false)
	#hurtbox.set_deferred("monitorable", false)
	#visible = false
