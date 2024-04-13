extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var lastPhysTime = Time.get_ticks_usec()

var sprite: Sprite2D
var spritePositions = [Vector2.ZERO, Vector2.ZERO]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
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
	#TODO: flip to always face a dummy opponent, keep track of directions for blocking
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	
	lastPhysTime = Time.get_ticks_usec()
