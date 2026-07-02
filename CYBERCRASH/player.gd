class_name Player
extends CharacterBody3D

# Constants
const BASE_SPEED := 16.0			## Default movement speed
const BASE_JUMP_VELOCITY := 6.0	## Default jump velocity
const BASE_DECELERATION := 0.8	## Default deceleration

# Signals
signal shoot(bullets: int, reload: bool)	## Player shoots
signal hurt(amount: int, health: int) ## Nine Inch Nails?

# Pseudo-constant Static Variables
static var MAX_HEALTH := 100

# Static Variables
static var pos := Vector3.ZERO
static var crouching := false
static var hit_something := 0.0
static var clip_size := 2
static var bullets_loaded := clip_size
static var health := MAX_HEALTH

# Pseudo-constants
var speed := BASE_SPEED	## Player move speed
var jump_velocity := BASE_JUMP_VELOCITY
var deceleration := BASE_DECELERATION	## Multiplier for decel

# General Variables
var speed_boost_time = 0.0	## How long left on speed boost
var camera_direction := Vector3.ZERO		## Direction of camera
var double_jump := true	## Can the player double jump
var is_crouching := false	## Is the player crouching
var iframes := 0.0

func _ready() -> void:
	#$Texture.hide()
	pass

func _physics_process(delta: float) -> void:
	set_look_direction()
	calculate_speed(delta)
	player_movement(delta)
	player_shoot()
	
	Player.crouching = is_crouching
	Player.pos = self.global_position
	iframes -= delta
	iframes = max(iframes, 0.0)
	
	if Input.is_key_pressed(KEY_H):
		get_tree().call_deferred("reload_current_scene")
		# TEMPORARY

func set_look_direction() -> void:
	var target := CameraController.get_camera_direction()
	camera_direction = target

## Sums up all the speed bonuses for the player, as well
## as other physics-related variables such as deceleration.
func calculate_speed(_delta: float) -> void:
	# Speed calculations
	speed = BASE_SPEED
	
	if Input.is_action_pressed("CROUCH"):
		speed /= 2.0
		is_crouching = true
	else:
		is_crouching = false
	
	# Deceleration calculations
	deceleration = BASE_DECELERATION

## Makes the player move
func player_movement(delta: float) -> void:
	# Add the gravity.
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
				power, 0.1, Modifier.Fade.QUADRATIC
				)
			CameraController.set_fov_mod(&"AIRBORNE_FADE", modifier)
			CameraController.del_fov_mod(&"AIRBORNE")
	
	# Handle jump.
	if Input.is_action_just_pressed("JUMP"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif double_jump:
			double_jump = false
			velocity.y = jump_velocity * 1.25
	
	if Input.is_action_pressed("CROUCH"):
		velocity.y = min(velocity.y, -1.0)
		velocity.y -= delta * 4
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("LEFT", "RIGHT", "FORWARDS", "BACKWARDS")
	if input_dir:
		# The vector projected "forward" from the player along 2d space by the yaw
		var forward := Vector2(sin(camera_direction.y), cos(camera_direction.y))
		var side := Vector2(forward.y, -forward.x)
		forward *= input_dir.y
		side *= input_dir.x
		
		var direction := (forward + side)
		# NOTE: direction is always normalised. The proof is
		# left as an exercise for the reader.
		
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
	elif CameraController.has_fov_mod(&"MOVEMENT"):
		var power: float = CameraController.get_fov_mod(&"MOVEMENT").value
		var modifier := Modifier.of(
			power, 0.25, Modifier.Fade.CUSTOM_EXP, 4.0
			)
		
		CameraController.set_fov_mod(&"MOVEMENT_FADE", modifier)
		CameraController.del_fov_mod(&"MOVEMENT")
	
	move_and_slide()


## Checks for the player attempting to shoot
func player_shoot() -> void:
	if Input.is_action_just_pressed("ATTACK_RIGHT"):
		if bullets_loaded > 0:
			$Timers/Reload.stop()
			gun_fire()
			bullets_loaded -= 1
			shoot.emit(bullets_loaded, false)
			if bullets_loaded < 1:
				$Timers/Reload.start()
	if Input.is_action_just_pressed("RELOAD"):
		if $Timers/Reload.is_stopped():
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
		if collider is Enemy:
			collider.take_damage(30.0)
			Player.hit_something = 1.0

func damage(amount: int, iframe := 0.1) -> int:
	if iframes > 0.0:
		return Player.health
	Player.health -= amount
	Player.health = clampi(Player.health, 0, Player.MAX_HEALTH)
	hurt.emit(amount, Player.health)
	iframes += iframe
	if Player.health <= 0:
		ScreenTransition.change_scene("res://Interfaces/death_scene.tscn")
	return Player.health

## Player has reloaded
func _on_reload_cooldown_timeout() -> void:
	bullets_loaded = clip_size
	shoot.emit(bullets_loaded, true)
