extends CharacterBody2D

const SPEED = 300.0
@export var currentSpeed = SPEED

var maxHealth = 100
var health = 100
var dead = false
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

var hud: CanvasLayer
var healthBar: ColorRect

var pauseMenu: Control
var pauseBg: Control
var optionsMenu: Control

func _ready():
	dead = false
	get_node("body collider").disabled = false
	currentSpeed = SPEED
	health = maxHealth
	
	hud = get_node("/root/level/HUD")
	healthBar = hud.get_node("in-game/health fill")
	invulnTimer = get_node("invuln timer")
	levelResetTimer = get_node("level reset")
	
	spriteRoot = get_node("sprite root")
	spritePositions[0] = spriteRoot.global_position
	spritePositions[1] = spriteRoot.global_position
	charSprite = get_node("sprite root/sprite")
	summonSprite = get_node("sprite root/summon sprite")
	anim = get_node("AnimationPlayer")
	anim.play("stand")
	
	pauseMenu = hud.get_node("pause menu")
	pauseBg = hud.get_node("pause bg")
	optionsMenu = hud.get_node("options menu")
	
	pauseMenu.visible = false
	pauseBg.visible = false
	optionsMenu.visible = false
	
	pauseMenu.get_node("resume").connect("pressed", unpauseGame)
	pauseMenu.get_node("options").connect("pressed", openOptionsMenu)
	pauseMenu.get_node("quit").connect("pressed", _on_quit_pressed)
	optionsMenu.get_node("exit button").connect("pressed", closeOptionsMenu)
	
	hud.get_node("in-game").visible = true
	hud.get_node("dead").visible = false

func _unhandled_input(event):
	if dead: return
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		pauseGame()
		#todo unpause with esc

func pauseGame():
	pauseBg.visible = true
	pauseMenu.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func unpauseGame():
	pauseBg.visible = false
	optionsMenu.visible = false
	pauseMenu.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

func openOptionsMenu():
	optionsMenu.visible = true
	pauseMenu.visible = false

func closeOptionsMenu():
	optionsMenu.visible = false
	pauseMenu.visible = true

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func next_level():
	summonActive = false
	currentSpeed = SPEED
	invulnerable = true
	invulnTimer.start()
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
		show_summon_menu()
		crystalsCollected = 0

func show_summon_menu():
	canPickup = false
	#show summon menu, pause game
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	hud.get_node("pause bg").visible = true
	hud.get_node("summon select").visible = true
	
	#summonActive = true
	#invulnTimer.stop()
	#invulnerable = true
	#anim.play("summon")
	#anim.queue("summon_run")

func close_summon_menu():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	hud.get_node("pause bg").visible = false
	hud.get_node("summon select").visible = false

func _take_damage(body, dmg):
	if invulnerable: return
	get_node("sounds/hurt").play()
	invulnerable = true
	invulnTimer.start()
	health -= dmg
	healthBar.size.x = max((health as float / maxHealth) * 360.0, 0)
	if health == 0:
		dead = true
		#todo show game over screen
		visible = false
		get_node("body collider").disabled = true
		hud.get_node("dead").visible = true
	#todo death, hurt anim

func _on_invuln_timer_timeout():
	#todo invuln effect
	invulnerable = false

func _on_enemy_hit(area):
	#todo score
	if area.get_parent().get_parent().name == "enemies":
		area.get_parent().die()
		get_node("sounds/kill").play()

func _on_level_reset_timeout():
	canPickup = true
