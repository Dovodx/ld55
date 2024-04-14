extends CharacterBody2D

var maxHealth = 15.0
var health = maxHealth
var dead = false

const SPEED = 400.0
var damage = 15
var angleVariationDeg = 30
var moveTimer: Timer
var stunTimer: Timer
var player: Node2D

var sprite: Sprite2D
var spriteRoot: Node2D
var spritePositions = [Vector2.ZERO, Vector2.ZERO]
var lastPhysTime = Time.get_ticks_usec()

var hitbox: Area2D
var hurtbox: Area2D
var healthbar: ColorRect

func _ready():
	dead = false
	moveTimer = get_node("move timer")
	stunTimer = get_node("stun timer")
	moveTimer.start()
	player = get_node("/root/level/player")
	
	sprite = get_node("sprite root/sprite")
	spriteRoot = get_node("sprite root")
	spritePositions[0] = spriteRoot.global_position
	spritePositions[1] = spriteRoot.global_position
	healthbar = get_node("sprite root/healthbar")
	
	hitbox = get_node("hitbox")
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	hurtbox = get_node("hurtbox")
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	visible = true
	
	hitbox.body_entered.connect(Callable(player._take_damage.bind(damage)))

func _process(delta):
	var timeDiff = (Time.get_ticks_usec() - lastPhysTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	spriteRoot.global_position = spritePositions[0].lerp(
		spritePositions[1], lerpWeight
	)

func _physics_process(delta):
	if !dead:
		velocity *= 0.98
		sprite.flip_h = velocity.x > 0
	else:
		velocity = Vector2.ZERO

	if is_on_wall() and stunTimer.is_stopped():
		if get_wall_normal().x != 0:
			velocity.x *= -1
		if get_wall_normal().y != 0:
			velocity.y *= -1

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()

func _on_movement_timer_timeout():
	velocity = (player.global_position - global_position).normalized().rotated(deg_to_rad(randi_range(-angleVariationDeg, angleVariationDeg) / 2.0)) * SPEED

func stun(time):
	moveTimer.stop()
	stunTimer.wait_time = time
	stunTimer.start()

func take_damage(dmg):
	if dead: return
	health -= dmg
	healthbar.size.x = 30.0 * health / maxHealth
	if health <= 0:
		die()

func die():
	if dead: return
	get_node("/root/level/spawner").enemy_dead()
	dead = true
	call_deferred("queue_free")

func _on_stun_timer_timeout():
	moveTimer.start()
