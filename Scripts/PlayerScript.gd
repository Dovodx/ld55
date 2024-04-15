extends CharacterBody2D

const SPEED = 300.0
var currentSpeed = SPEED
@export var summons: Array[PackedScene]
@export var summonEffect: PackedScene

var maxHealth = 100.0
var health = 100.0
var dead = false
var invulnerable = false
var invulnTimer: Timer

var crystalsCollected = 0
var crystalsNeeded = 4
var summonActive = false

var spriteRoot: Node2D
var spritePositions = [Vector2.ZERO, Vector2.ZERO]
var charSprite: Sprite2D
var summonSprite: Sprite2D
var lastPhysTime = Time.get_ticks_usec()

var anim: AnimationPlayer
@export var particles: PackedScene

var hud: CanvasLayer
var healthBar: ColorRect

var pauseMenu: Control
var pauseBg: Control
var optionsMenu: Control

signal hit_enemy(area, dmg)

func _ready():
	Global.reset_stats()
	dead = false
	get_node("body collider").disabled = false
	currentSpeed = SPEED
	health = maxHealth
	
	hud = get_node("/root/level/HUD")
	healthBar = hud.get_node("in-game/health fill")
	invulnTimer = get_node("invuln timer")
	
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
	hud.get_node("summon select").visible = false
	pauseBg.visible = false
	optionsMenu.visible = false
	
	pauseMenu.get_node("resume").connect("pressed", unpauseGame)
	pauseMenu.get_node("options").connect("pressed", openOptionsMenu)
	pauseMenu.get_node("quit").connect("pressed", _on_quit_pressed)
	optionsMenu.get_node("exit button").connect("pressed", closeOptionsMenu)
	
	hud.get_node("in-game").visible = true
	hud.get_node("dead").visible = false
	
	hud.get_node("dead/retry").connect("pressed", _on_retry_pressed)
	hud.get_node("dead/quit").connect("pressed", _on_quit_pressed)
	
	for button in hud.get_node("summon select").get_children():
		if button.name == "bg" or button.get_index() > 5:
			continue
		button.connect("pressed", summon.bind(button.get_index() - 1))

func _unhandled_input(event):
	if dead: return
	if event.is_action_pressed("ui_cancel"):
		pauseGame()
		#todo unpause with esc

func pauseGame():
	pauseBg.visible = true
	pauseMenu.visible = true
	get_tree().paused = true

func unpauseGame():
	pauseBg.visible = false
	optionsMenu.visible = false
	pauseMenu.visible = false
	get_tree().paused = false

func openOptionsMenu():
	optionsMenu.visible = true
	pauseMenu.visible = false

func closeOptionsMenu():
	optionsMenu.visible = false
	pauseMenu.visible = true

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/fightscene.tscn")

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func next_level():
	summonActive = false
	currentSpeed = SPEED
	invulnerable = true
	invulnTimer.start()

func _process(delta):
	var timeDiff = (Time.get_ticks_usec() - lastPhysTime) / 1000000.0
	var lerpWeight = timeDiff / (1.0 / Engine.physics_ticks_per_second)
	spriteRoot.global_position = spritePositions[0].lerp(
		spritePositions[1], lerpWeight
	)

func _physics_process(delta):
	if dead: return
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
	if !anim.current_animation == "hurt":
		if movementVector.length() == 0:
			anim.play("stand")
		else:
			anim.play("run")

	move_and_slide()
	
	spritePositions[0] = spritePositions[1]
	spritePositions[1] = global_position
	lastPhysTime = Time.get_ticks_usec()

func get_crystal(crystal):
	crystal.visible = false
	crystal.set_deferred("monitoring", false)
	crystal.set_deferred("monitorable", false)
	crystalsCollected += 1
	Global.crystalsCollected += 1
	
	get_node("sounds/pickup").play()
	if !summonActive and crystalsCollected >= crystalsNeeded:
		show_summon_menu()
		crystalsCollected = 0
		crystalsNeeded += 1
		
	var crystalUncollected = false
	for c in get_node("/root/level/crystals").get_children():
		if c.visible:
			crystalUncollected = true
			break
	if !crystalUncollected:
		get_node("/root/level/spawner").respawn_crystals()
	hud.get_node("in-game/crystal text").text = "[right]" + str(crystalsCollected) + "/" + str(crystalsNeeded)

func show_summon_menu():
	get_tree().paused = true
	hud.get_node("pause bg").visible = true
	hud.get_node("summon select").visible = true
	#RIP rideable Mr. Chompy
	#summonActive = true
	#invulnTimer.stop()
	#invulnerable = true
	#anim.play("summon")
	#anim.queue("summon_run")

func close_summon_menu():
	get_tree().paused = false
	hud.get_node("pause bg").visible = false
	hud.get_node("summon select").visible = false

func summon(monsterNum):
	var summonToSpawn = summons[monsterNum].instantiate()
	summonToSpawn.global_position = global_position
	get_tree().get_root().get_node("level/summons").add_child(summonToSpawn)
	close_summon_menu()
	Global.summonCounts[monsterNum] += 1
	
	var effect = summonEffect.instantiate()
	effect.global_position = global_position
	get_tree().get_root().get_node("level/summons").add_child(effect)
	get_node("sounds/summon").play()

func heal(amount):
	if dead: return
	var healthBefore = health
	health = clamp(health + amount, 0, maxHealth)
	Global.totalHealing += health - healthBefore
	#Spawn particle effect
	var emitterToSpawn = particles.instantiate()
	get_tree().get_root().get_node("level/player/sprite root").add_child(emitterToSpawn)
	emitterToSpawn.position = Vector2.ZERO
	update_healthbar()

func _take_damage(body, dmg):
	if invulnerable or body != get_node("."): return
	get_node("sounds/hurt").play()
	anim.play("hurt")
	anim.queue("stand")
	invulnerable = true
	invulnTimer.start()
	health -= dmg
	update_healthbar()
	if health <= 0:
		dead = true
		visible = false
		get_node("/root/level/music").stop()
		get_node("/root/level/spawner").stop_spawning()
		get_node("body collider").set_deferred("disabled", true)
		pauseBg.visible = true
		hud.get_node("dead/stats").text = "[left]" + str(Global.enemiesSlain) + "\n" + str(Global.crystalsCollected) + "\n" + str(Global.totalHealing)
		
		var summonCountText = "[left]"
		for i in 5:
			summonCountText += str(Global.summonCounts[i])
			if i < 4:
				summonCountText += "\n"
		hud.get_node("dead/summon stats").text = summonCountText
		hud.get_node("dead").visible = true

func update_healthbar():
	healthBar.size.x = max((health as float / maxHealth) * 360.0, 0)

func _on_invuln_timer_timeout():
	invulnerable = false

func _hit_enemy(area, dmg):
	if area.get_parent().get_parent().name == "enemies":
		area.get_parent().take_damage(dmg)
		get_node("sounds/kill").play()
