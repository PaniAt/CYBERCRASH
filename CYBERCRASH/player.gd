class_name Player
extends CharacterBody3D

# Constants
const BASE_SPEED := 16.0		## Default movement speed
const BASE_JUMP_VELOCITY := 6.0	## Default jump velocity
const BASE_DECELERATION := 0.8	## Default deceleration
const ABILITY_COOLDOWNS: Dictionary[Ability, float] = {
	Ability.NONE: 0.0,
	Ability.XRAY: 45.0,
	Ability.GLITCH: 2.0,
	Ability.AGILITY: 0.0,
	Ability.GLITCH_FAR: 1.7,
	Ability.SLOW_TIME: 30.0,
	Ability.SWAP: 4.0,
	Ability.CORRUPT: 30.0,
	Ability.PREDICT: 0.0,
	Ability.INVISIBILITY: 30.0,
	Ability.TRIPLE_JUMP: 0.0,
	Ability.HIGH_JUMP: 0.0,
	Ability.BASH: 0.0,
}
const ABILITY_COSTS: Dictionary[Ability, float] = {
	Ability.NONE: 0.0,
	Ability.XRAY: 25.0,
	Ability.GLITCH: 15.0,
	Ability.AGILITY: 0.0,
	Ability.GLITCH_FAR: 15.0,
	Ability.SLOW_TIME: 50.0,
	Ability.SWAP: 40.0,
	Ability.CORRUPT: 50.0,
	Ability.PREDICT: 0.0,
	Ability.INVISIBILITY: 40.0,
	Ability.TRIPLE_JUMP: 0.0,
	Ability.HIGH_JUMP: 0.0,
	Ability.BASH: 0.0,
}
const ITEM_WHEEL_SCENE = preload("res://Interfaces/item_wheel.tscn")

# Signals
signal shoot()	## Player shoots
signal hurt(amount: int, health: int) ## Nine Inch Nails?
signal heal(amount: int, health: int) ## When the player unhurts 

## Enum for player abilities
enum Ability
{
	NONE, ## No abilty
	XRAY, ## Can see through walls
	GLITCH, ## Can teleport
	AGILITY, ## Moves faster & jumps higher
	GLITCH_FAR, ## Glitch 2: Electric Boogaloo
	SLOW_TIME, ## Slows down time for enemies
	SWAP, ## Swaps position with and enemy
	CORRUPT, ## Look at enemies to kill them
	PREDICT, ## Passively sees through walls
	INVISIBILITY, ## Enemies can't detect the player
	TRIPLE_JUMP, ## Triple jump
	HIGH_JUMP, ## High jump
	BASH, ## Run into enemies to deal damage
}

# Pseudo-constant Static Variables
static var MAX_HEALTH := 100
static var MAX_SPRINT := 25.0
static var MAX_CONCENTRATION := 100.0

# Static Variables
static var pos := Vector3.ZERO
static var crouching := false
static var hit_something := 0.0
static var weapon_inventory: Array[Weapon] = [
	Weapon.of(25000, 2, 0.2, 0.7) # Default weapon
]
static var weapon := weapon_inventory[0]
static var queued_weapon := -1
static var health := MAX_HEALTH
static var sprint := MAX_SPRINT
static var ability := Ability.NONE
static var concentration := MAX_CONCENTRATION
static var slow_time := 0.0
static var corrupt_time := 0.0
static var invisible_time := 0.0
static var dead := false

# Pseudo-constants
var speed := BASE_SPEED	## Player move speed
var jump_velocity := BASE_JUMP_VELOCITY
var deceleration := BASE_DECELERATION	## Multiplier for decel

# General Variables
var camera_direction := Vector3.ZERO	## Direction of camera
var double_jump := true	## Can the player double jump
var triple_jump := false ## Can the player triple jump
var is_crouching := false	## Is the player crouching
var iframes := 0.0
var is_sprinting := false
var can_use_ability := true
var regen_concentration := MAX_CONCENTRATION
var item_wheel: CanvasLayer

func _ready() -> void:
	# This is usually for debugging purposes
	
	Settings.update_keybinds()
	$Texture.hide()
	
	pass

func _physics_process(delta: float) -> void:
	if CameraController.paused:
		return
	if dead:
		move_and_slide() # Process remaining velocity
		return # Nope your too late i already died
	
	set_look_direction()
	calculate_speed(delta)
	player_movement(delta)
	player_hotbar()
	player_shoot()
	player_abilities(delta)
	
	Player.crouching = is_crouching
	Player.pos = self.global_position
	iframes -= delta
	iframes = max(iframes, 0.0)
	
	if Input.is_key_pressed(KEY_H):
		restart()
		get_tree().call_deferred("reload_current_scene")
		# TEMPORARY
	
	if Input.is_key_pressed(KEY_B):
		get_tree().paused = true
		# TEMPORARY

#func save_to_file(file_path: String) -> int:
	#var file := FileAccess.open(file_path, FileAccess.WRITE_READ)
	#var content: PackedStringArray
	#content.push_back("在" + get_tree().current_scene.scene_file_path)
	#var weaponry_string = ""
	#for weap: Weapon in weapon_inventory:
		#weaponry_string += weap.str_encode() + "三"
	#content.push_back("死" + weaponry_string)
	#content.push_back("比" + Player.weapon.str_encode())
	#content.push_back("我" + str(Player.health))
	#content.push_back("觉" + str(Player.concentration))
	#content.push_back("会" + str(Player.ability))
	#var save: String = ""
	#for line: String in content:
		#save += line + '\n'
	#var file_hash := hash(save)
	#file_hash ^= file_hash << 17
	#file_hash ^= file_hash >> 13
	#file_hash ^= file_hash << 5
	#save = str(file_hash) + '\n' + save
	#file.store_string(save)
	#return 0
#
#func load_from_file(file_path: String) -> int:
	#var file := FileAccess.open(file_path, FileAccess.READ)
	#var file_hash := file.get_line()
	#var contents := file.get_as_text(false)
	#if len(contents.split("\n", true, 1)) != 2:
		#return 1
	#contents = contents.split("\n", true, 1)[1]
	#var expected_hash := hash(contents)
	#expected_hash ^= expected_hash << 17
	#expected_hash ^= expected_hash >> 13
	#expected_hash ^= expected_hash << 5
	#if str(expected_hash) != file_hash:
		#return 1
	#var scene := ""
	#var newinv: Array[Weapon]
	#var newweapon: Weapon
	#var newhp = 0
	#var newcon = 0
	#var newabi: Ability
	#for line: String in contents.split("\n"):
		#match line.substr(0, 1):
			#"在": # Level (zai)
				#scene = line.substr(1)
			#"死": # Inventory (si)
				#for weaponstr: String in line.substr(1).split("三"):
					#if weaponstr:
						#newinv.push_back(Weapon.ofstr(weaponstr))
			#"比": # Weapon (bi)
				#newweapon = Weapon.ofstr(line.substr(1))
			#"我": # Health (wo)
				#newhp = int(line.substr(1))
			#"觉": # Concentration (jue)
				#newcon = int(line.substr(1))
			#"会": # Ability (hui)
				#newabi = int(line.substr(1)) as Ability
	#ScreenTransition.change_scene(scene)
	#weapon_inventory = newinv
	#weapon = newweapon
	#health = newhp
	#concentration = newcon
	#ability = newabi	
	#return 0

static func restart() -> void:
	health = MAX_HEALTH
	sprint = MAX_SPRINT
	concentration = MAX_CONCENTRATION
	dead = false

func set_look_direction() -> void:
	var target := CameraController.get_camera_direction()
	camera_direction = target

## Sums up all the speed bonuses for the player, as well
## as other physics-related variables such as deceleration.
func calculate_speed(delta: float) -> void:
	# Speed calculations
	speed = BASE_SPEED
	jump_velocity = BASE_JUMP_VELOCITY
	
	# Sprinting calculations
	if Input.is_action_pressed("SPRINT") and sprint > 0.0:
		speed *= 1.25
		var power := 0.0
		if CameraController.has_fov_mod(&"SPRINT"):
			power = CameraController.get_fov_mod(&"SPRINT").value
		elif CameraController.has_fov_mod(&"SPRINT_FADE"):
			power = CameraController.get_fov_mod(&"SPRINT_FADE").value
			CameraController.del_fov_mod(&"SPRINT_FADE")
		power = lerp(power, 3.0, delta * 9.0)
		power = clampf(power, 0.0, 3.0)
		
		var modifier := Modifier.of(power, delta)
		CameraController.set_fov_mod(&"SPRINT", modifier)
		
		is_sprinting = true
	else:
		is_sprinting = false
		
		if CameraController.has_fov_mod(&"SPRINT"):
			var power := CameraController.get_fov_mod(&"SPRINT").value
			var modifier := Modifier.of(power, 0.25, Modifier.Fade.QUADRATIC)
			CameraController.set_fov_mod(&"SPRINT_FADE", modifier)
			CameraController.del_fov_mod(&"SPRINT")
		
		sprint += delta
		sprint = min(sprint, MAX_SPRINT)
	
	if Input.is_action_pressed("CROUCH"):
		speed /= 2.0
		is_crouching = true
	else:
		is_crouching = false
	
	# Agility ability
	if ability == Ability.AGILITY: # Hey! That rhymes.
		speed *= 1.2
		jump_velocity *= 1.2
	elif ability == Ability.TRIPLE_JUMP:
		speed *= 1.2
		jump_velocity *= 1.1
	elif ability == Ability.HIGH_JUMP:
		speed *= 1.3
		jump_velocity *= 1.5
	elif ability == Ability.BASH:
		speed *= 1.5
		jump_velocity *= 0.9
	
	# Deceleration calculations
	deceleration = BASE_DECELERATION

## Makes the player move (muscles make the body move)
func player_movement(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y < -1.0:
			velocity.y -= delta * 30.0
		var power := 0.5
		if CameraController.has_fov_mod(&"AIRBORNE"):
			power = CameraController.get_fov_mod(&"AIRBORNE").get_strength()
			power = lerp(power, 2.0, delta * 9.0)
		elif CameraController.has_fov_mod(&"AIRBORNE_FADE"):
			power = CameraController.get_fov_mod(&"AIRBORNE_FADE").get_strength()
			power = lerp(power, 2.0, delta * 9.0)
			CameraController.del_fov_mod(&"AIRBORNE_FADE")
		power = clampf(power, 0.0, 2.0)
		var modifier := Modifier.of(power, delta)
		CameraController.set_fov_mod(&"AIRBORNE", modifier)
	else:
		double_jump = true
		if CameraController.fov_modifiers.has(&"AIRBORNE"):
			var power := CameraController.get_fov_mod(&"AIRBORNE").get_strength()
			var modifier := Modifier.of(
				power, 0.52, Modifier.Fade.QUADRATIC
				)
			CameraController.set_fov_mod(&"AIRBORNE_FADE", modifier)
			CameraController.del_fov_mod(&"AIRBORNE")
		if ability == Ability.TRIPLE_JUMP:
			triple_jump = true
	
	# Jump
	if Input.is_action_just_pressed("JUMP"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif double_jump:
			double_jump = false
			if ability == Ability.HIGH_JUMP:
				velocity.y = jump_velocity * 2.0
			else:
				velocity.y = jump_velocity * 1.25
		elif triple_jump:
			triple_jump = false
			velocity.y = jump_velocity * 1.25
	
	# Crouch
	if Input.is_action_pressed("CROUCH"):
		velocity.y = min(velocity.y, -1.0)
		velocity.y -= delta * 4
	
	# (16/07/2026) I realise that Godot does indeed have an inbuilt
	# way to achieve this exact same effect. I do not wish to change
	# this code however, if it ain't broke, don't fix it.
	# But naturally, Godot has inbuilt methods to make easy any challenge
	# that may arise during programming. Should've known better.
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("LEFT", "RIGHT", "FORWARDS", "BACKWARDS")
	if input_dir:
		# The vector projected "forward" from the player along 2d space by the yaw
		var forward := Vector2(sin(camera_direction.y), cos(camera_direction.y))
		var side := Vector2(forward.y, -forward.x)
		forward *= input_dir.y
		side *= input_dir.x
		
		var direction := (forward + side)
		# NOTE: direction is always normalised. The proof
		# NOTE: is left as an exercise for the reader.
		
		if Math.hlen_sqr(velocity) <= speed * speed:
			velocity.x = direction.x * speed
			velocity.z = direction.y * speed
	
	velocity.x *= deceleration
	velocity.z *= deceleration
	
	if input_dir:
		var power := 1.0
		if CameraController.has_fov_mod(&"MOVEMENT"):
			power = CameraController.get_fov_mod(&"MOVEMENT").get_strength()
			power = lerp(power, 3.0, delta * 6.0)
		elif CameraController.has_fov_mod(&"MOVEMENT_FADE"):
			power = CameraController.get_fov_mod(&"MOVEMENT_FADE").get_strength()
			power = lerp(power, 3.0, delta * 6.0)
			CameraController.del_fov_mod(&"MOVEMENT_FADE")
		power = clampf(power, 0.0, 3.0)
		
		var modifier := Modifier.of(power, 1.0)
		CameraController.set_fov_mod(&"MOVEMENT", modifier)
		if is_sprinting:
			sprint -= delta
	elif CameraController.has_fov_mod(&"MOVEMENT"):
		var power: float = CameraController.get_fov_mod(&"MOVEMENT").value
		var modifier := Modifier.of(
			power, 0.25, Modifier.Fade.QUADRATIC	
			)
		
		CameraController.set_fov_mod(&"MOVEMENT_FADE", modifier)
		CameraController.del_fov_mod(&"MOVEMENT")
	
	move_and_slide()

func player_hotbar() -> void:
	if queued_weapon != -1:
		switch_weapon(queued_weapon)
		queued_weapon = -1
	
	if Input.is_action_just_pressed("ITEMWHEEL"):
		CameraController.free_mouse = true
		item_wheel = ITEM_WHEEL_SCENE.instantiate() as CanvasLayer
		add_sibling(item_wheel)
	elif Input.is_action_just_released("ITEMWHEEL"):
		CameraController.free_mouse = false
		if item_wheel:
			item_wheel.exit()
	
	if Input.is_action_just_pressed("HOTBAR_1"):
		switch_weapon(0)
	elif Input.is_action_just_pressed("HOTBAR_2"):
		switch_weapon(1)
	elif Input.is_action_just_pressed("HOTBAR_3"):
		switch_weapon(2)

## In order to static call switch_weapon()
static func queue_weapon(index: int) -> void:
	queued_weapon = index

func switch_weapon(index: int) -> void:
	if len(Player.weapon_inventory) <= index:
		return
	
	weapon = weapon_inventory[index]
	weapon.can_shoot = false
	weapon.reload()
	$Timers/Attack.wait_time = weapon.attack_speed
	$Timers/Attack.start()
	$Timers/Reload.wait_time = weapon.reload_speed
	$Timers/Reload.stop()

## Checks for the player attempting to shoot
func player_shoot() -> void:
	if Input.is_action_just_pressed("ATTACK_LEFT"):
		if weapon.is_fireable():
			$Timers/Reload.stop()
			gun_fire()
			weapon.can_shoot = false
			$Timers/Attack.wait_time = weapon.attack_speed
			$Timers/Attack.start()
			weapon.bullets -= 1
			shoot.emit()
			if not weapon.is_loaded():
				$Timers/Reload.wait_time = weapon.reload_speed
				$Timers/Reload.start()
	if Input.is_action_just_pressed("RELOAD"):
		if $Timers/Reload.is_stopped():
			$Timers/Reload.wait_time = weapon.reload_speed
			$Timers/Reload.start()

## Actually shooting the player's gun
func gun_fire() -> void:
	var dir := camera_direction
	var forward := Vector3(
		sin(dir.y) * cos(dir.x),
		-sin(dir.x), 
		cos(dir.y) * cos(dir.x))
	
	$BulletParticles.rotation = dir
	$BulletParticles.emit_particle(
		Transform3D.IDENTITY, Vector3(0.0, 0.0, -100.0),
		Color.WHITE, Color.WHITE, 0
	)
	
	$Raycast.target_position = forward * -120.0
	$Raycast.force_raycast_update()
	
	if $Raycast.is_colliding():
		var collider = $Raycast.get_collider()
		if collider is Enemy or collider is ServerBoss:
			collider.take_damage(weapon.damage)
			Player.hit_something = 1.0

func player_abilities(delta: float) -> void:
	# Slow time ability
	if slow_time > 0.0:
		slow_time = max(slow_time - delta, 0.0)
		Enemy.time_scale = 0.25
	else:
		slow_time = 0.0
		Enemy.time_scale = move_toward(Enemy.time_scale, 1.0, delta)
	
	# Corrupt abiltiy
	if corrupt_time > 0.0:
		corrupt_time = max(corrupt_time - delta, 0.0)
		var target_dir: Vector2
		var ang_dist: float
		var dist: float
		for enemy: Enemy in get_tree().get_nodes_in_group(&"Enemies"):
			target_dir = Math.atan3(Player.pos - enemy.global_position + Vector3(0.0, 1.0, 0.0))
			ang_dist = Vector2(
				angle_difference(camera_direction.y, target_dir.x),
				angle_difference(camera_direction.x, target_dir.y)
				).length_squared()
			if ang_dist < 0.030461741978670857: # 0.030461741978670857 = rad(10˚) ** 2.0
				enemy.xray_time = 0.25
				enemy.take_damage(1)
			else:
				dist = (enemy.global_position - Player.pos).length_squared()
				if dist < 16.0:
					enemy.xray_time = 0.25
					enemy.take_damage(1)
	else:
		corrupt_time = 0.0
	
	# Invisibility ability
	if invisible_time > 0.0:
		invisible_time = max(invisible_time - delta, 0.0)
	else:
		invisible_time = 0.0
	
	# Predict ability
	if Player.ability == Ability.PREDICT:
		var target_dir: Vector2
		var ang_dist: float
		for enemy: Enemy in get_tree().get_nodes_in_group(&"Enemies"):
			target_dir = Math.atan3(Player.pos - enemy.global_position)
			ang_dist = Vector2(
				angle_difference(camera_direction.y, target_dir.x),
				angle_difference(camera_direction.x, target_dir.y)
			).length_squared()
			if ang_dist < 0.6168502750680849: # 0.6168502750680849 = rad(45˚) ** 2.0
				enemy.xray_time = move_toward(enemy.xray_time, 1.0, delta * 4.0)
	
	# Ability triggering
	if $Timers/Ability.is_stopped() and concentration < regen_concentration:
		concentration += delta * 12.0
		concentration = clampf(concentration, 0.0, regen_concentration)
	if ABILITY_COSTS[ability] > concentration:
		return
	if Input.is_action_just_pressed("ATTACK_RIGHT") and can_use_ability:
		can_use_ability = false
		concentration -= ABILITY_COSTS[ability]
		regen_concentration = concentration + clampf(ABILITY_COSTS[ability], 0.0, 25.0)
		var cooldown = use_player_ability()
		if cooldown == 0.0: # No ability used value
			can_use_ability = true # We actually can
		else:
			$Timers/Ability.wait_time = cooldown
			$Timers/Ability.start()

## Triggers a player ability function, and returns the
## cooldown depending on which ability was activated
func use_player_ability() -> float:
	match ability:
		Ability.NONE:
			pass
		Ability.XRAY:
			use_xray_ability()
		Ability.GLITCH:
			use_glitch_ability(16.0)
		Ability.AGILITY:
			pass
		Ability.GLITCH_FAR:
			use_glitch_ability(24.0)
		Ability.SLOW_TIME:
			use_slow_time_ability()
		Ability.SWAP:
			use_swap_ability()
		Ability.CORRUPT:
			use_corrupt_ability()
		Ability.PREDICT:
			pass
		Ability.INVISIBILITY:
			use_invisibility_ability()
		Ability.TRIPLE_JUMP:
			pass
		Ability.HIGH_JUMP:
			pass
		Ability.BASH:
			pass
	
	return ABILITY_COOLDOWNS[ability] # Fallback

func use_xray_ability() -> void:
	for enemy: Enemy in get_tree().get_nodes_in_group(&"Enemies"):
		enemy.xray_time = 25.0

func use_glitch_ability(power: float) -> void:
	var disp = Math.proj(camera_direction)
	disp *= (power + 1.0) # (+1 discarded later)
	$Raycast.target_position = disp
	$Raycast.force_raycast_update()
	var target: Vector3
	if $Raycast.is_colliding():
		target = $Raycast.get_collision_point()
		target -= $Raycast.position
	else:
		target = global_position + disp
	
	# Move 1 unit towards the player again (prevent into walls)
	target = Math.towards(target, global_position, 1.0)
	
	global_position = target

func use_slow_time_ability() -> void:
	slow_time = 15.0

func use_swap_ability() -> void:
	var disp = Math.proj(camera_direction)
	disp *= 64.0
	$Raycast.target_position = disp
	$Raycast.force_raycast_update()
	if $Raycast.is_colliding():
		if $Raycast.get_collider() is Enemy:
			var target: Vector3 = $Raycast.get_collider().global_position
			$Raycast.get_collider().global_position = global_position
			global_position = target
			iframes += 0.25

func use_corrupt_ability() -> void:
	corrupt_time = 10.0

func use_invisibility_ability() -> void: # Hey that rhymes!
	Player.invisible_time = 15.0

func damage(amount: int, iframe := 0.1) -> int:
	if ability == Ability.BASH and velocity.length_squared() > 1.0:
		amount /= 4
	if iframes > 0.0:
		return Player.health
	Player.health -= amount
	Player.health = clampi(Player.health, 0, Player.MAX_HEALTH)
	hurt.emit(amount, Player.health)
	iframes += iframe
	if Player.health <= 0:
		Player.dead = true
		ScreenTransition.change_scene("res://Interfaces/death_scene.tscn")
	return Player.health

## Can't use the word "heal" twice, but it has basically
## the exact same effect.
func undamage(amount: int) -> int:
	Player.health += amount
	Player.health = clampi(Player.health, 0, Player.MAX_HEALTH)
	heal.emit(amount, Player.health)
	return Player.health

## Player has reloaded
func _on_reload_cooldown_timeout() -> void:
	weapon.reload()

func _on_attack_timeout() -> void:
	weapon.can_shoot = true

func _on_ability_timeout() -> void:
	can_use_ability = true

func _on_bash_area_body_entered(body: Enemy) -> void:
	if ability != Ability.BASH or not body is Enemy:
		return
	
	if velocity.length_squared() > 1.0:
		body.take_damage(int(velocity.length_squared() / 16))
		CameraController.camera_shake_time = 0.25
		CameraController.camera_shake_power = 0.3
		body.velocity.y += 6.0
		iframes += 0.05
		if body.dead and not body.has_connections(&"die"):
			body.connect(&"die", _on_enemy_bash_death)
			body.collision_layer = 0

func _on_enemy_bash_death() -> void:
	undamage(10)
