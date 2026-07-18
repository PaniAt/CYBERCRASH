class_name EnemyDefault
extends CharacterBody3D

# WARNING This class is the old version of the enemy class for the
# WARNING demo version of the game. It is no longer supported and
# WARNING should not be used.

# Constants
const SPEED = 5.0
const MAX_HEALTH := 40.0
const TEXTURES: Array[CompressedTexture2D] = [
	preload("res://GFX/characters/enemy/enemy_0.png"),
	preload("res://GFX/characters/enemy/enemy_1.png"),
	preload("res://GFX/characters/enemy/enemy_2.png"),
	preload("res://GFX/characters/enemy/enemy_3.png"),
	preload("res://GFX/characters/enemy/enemy_4.png"),
	]

# Signals
signal die()

enum EnemyTexture
{
	NONE = 0, #     on screen
	IDLE = 1, # ... on screen
	NOTE = 2, # !!! on screen
	HURT = 3, # >:( on screen
	DEAD = 4, # X X on screen
}

# Variables
var health = MAX_HEALTH
var hurting_player := false
var can_hit_player := true
var strength := 30
var dead := false
var sees_player := false

func _ready() -> void:
	# ALERT: Don't make an instance of this please
	printerr(
		"ALERT: An instance of EnemyDefault was instantiated!
		This class is no longer supported internally, and WILL
		cause errors in the code."
	)

func _process(delta: float) -> void:
	tick_damage_flash(delta)
	look_for_player()

func try_hitting_player() -> void:
	if not hurting_player or not can_hit_player:
		return
	can_hit_player = false
	$Timers/Attack.start()
	for player: Player in get_tree().get_nodes_in_group("Players"):
		player.damage(strength, strength / 40.0)

func tick_damage_flash(delta: float) -> void:
	var healthmesh: Mesh = $HealthBar/Health.mesh
	var target = 2.0 * (self.health / MAX_HEALTH)
	healthmesh.size.x = lerpf(healthmesh.size.x, target, delta * 30.0)
	var tex := $Texture
	if tex.get_instance_shader_parameter("progress"):
		var dmg: float
		dmg = tex.get_instance_shader_parameter("progress")
		dmg -= delta * 10.0
		dmg = clampf(dmg, 0.0, 1.0)
		tex.set_instance_shader_parameter("progress", dmg)

func look_for_player() -> void:
	sees_player = Math.within(global_position, Player.pos, 10.0)

func _physics_process(delta: float) -> void:
	if dead: return # Nope your too late i already died
	
	try_hitting_player()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	

	# Get the input direction and handle the movement/deceleration.
	var direction = global_position.direction_to(Player.pos)
	if sees_player:
		# Look at the player
		var target = Math.atan2d(Player.pos, global_position)
		target -= PI / 2.0
		rotation.y = lerp_angle(rotation.y, target, delta * 12.0)
		# 你好 Mr. Cave， 我觉得你很好的老师。所以，请给我一百钱。
		# Actually move
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if self.health < self.MAX_HEALTH:
			set_texture(EnemyTexture.HURT)
		else:
			set_texture(EnemyTexture.NOTE)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		set_texture(EnemyTexture.IDLE)
	
	move_and_slide()

func take_damage(amount: float) -> float:
	velocity.y += amount / 10.0
	self.health = max(self.health - amount, 0.0)
	$Texture.set_instance_shader_parameter("progress", 1.0)
	if self.health <= 0.0 and not dead:
		enemy_die()
	return self.health

func enemy_die() -> void:
	dead = true
	set_texture(EnemyTexture.DEAD)
	
	await get_tree().create_timer(1.0).timeout
	CameraController.camera_shake_time += 0.15
	CameraController.camera_shake_power += 0.5
	const SCENE = preload("res://Effects/blood_explosion.tscn")
	var explosion := SCENE.instantiate() as Node3D
	explosion.position = position
	self.add_sibling(explosion)
	
	# This was put into a super method/class
	die.emit()
	call_deferred("queue_free")

func set_texture(texture: int) -> void:
	$Texture.mesh.material.albedo_texture = TEXTURES[texture]
	

func _on_hit_area_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	hurting_player = true

func _on_hit_area_body_exited(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	hurting_player = false

func _on_attack_timeout() -> void:
	can_hit_player = true
