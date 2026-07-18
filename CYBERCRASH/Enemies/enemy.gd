class_name Enemy
extends CharacterBody3D

# "Constants"
@export var MAX_SPEED: float
@export var MAX_HEALTH: int
@export var BASE_STRENGTH: int
@export var TEXTURES: Array[CompressedTexture2D]

# Signals
signal die() ## умерать

# Enum for texture indices
enum EnemyTexture
{
	NONE = 0,
	IDLE = 1,
	NOTE = 2,
	HURT = 3,
	DEAD = 4,
}

# Instance variables
@onready var health := MAX_HEALTH
@onready var speed := MAX_SPEED
@onready var hurting_player := false
@onready var can_hit_player := true
@onready var strength := BASE_STRENGTH
@onready var dead := false
@onready var sees_player := false
@onready var always_sees_player := false
@onready var xray_time := 0.0

func _ready() -> void:
	assert(len(TEXTURES) == 5, "Invalid texture array size, recieved: " + str(len(TEXTURES)))

func _process(delta: float) -> void:
	if CameraController.paused: return
	if always_sees_player:
		sees_player = true
	
	tick_damage_flash(delta)
	determine_texture(delta)

func _physics_process(delta: float) -> void:
	if CameraController.paused: return
	if dead: return # Nope your too late i already died
	
	try_hitting_player()
	enemy_movement(delta)

func tick_damage_flash(delta: float) -> void:
	var healthmesh: Mesh = $HealthBar/Health.mesh
	var target = (2.0 * self.health) / MAX_HEALTH
	healthmesh.size.x = lerpf(healthmesh.size.x, target, delta * 30.0)
	var tex := $Texture
	if tex.get_instance_shader_parameter("progress"):
		var dmg: float
		dmg = tex.get_instance_shader_parameter("progress")
		dmg -= delta * 10.0
		dmg = clampf(dmg, 0.0, 1.0)
		tex.set_instance_shader_parameter("progress", dmg)

func determine_texture(delta: float) -> void:
	if dead:
		set_texture(EnemyTexture.DEAD)
	elif sees_player:
		if self.health < self.MAX_HEALTH / 2.0:
			set_texture(EnemyTexture.HURT)
		else:
			set_texture(EnemyTexture.NOTE)
	else:
		set_texture(EnemyTexture.IDLE)
	
	if xray_time > 0.0:
		$Texture.mesh.material.stencil_mode = BaseMaterial3D.STENCIL_MODE_XRAY
		$Texture.mesh.material.stencil_color = Color(0.0, 1.0, 0.0, min(xray_time, 1.0))
		xray_time -= delta
	else:
		$Texture.mesh.material.stencil_mode = BaseMaterial3D.STENCIL_MODE_DISABLED
		$Texture.mesh.material.stencil_color = Color(0.0, 1.0, 0.0, 0.0)

func try_hitting_player() -> void:
	if not hurting_player or not can_hit_player:
		return
	
	can_hit_player = false
	$Timers/Attack.start()
	for player: Player in get_tree().get_nodes_in_group("Players"):
		player.damage(strength, strength / 40.0)

func enemy_movement(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the movement direction
	var direction = global_position.direction_to(Player.pos)
	if sees_player:
		# Look at the player
		var target = Math.atan2d(Player.pos, global_position)
		target -= PI / 2.0
		rotation.y = lerp_angle(rotation.y, target, delta * 12.0)
		
		# Actually move
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	move_and_slide()

func set_texture(textureID: int) -> void:
	$Texture.mesh.material.albedo_texture = TEXTURES[textureID]

func take_damage(amount: int) -> int:
	health = max(health - amount, 0)
	$Texture.set_instance_shader_parameter("progress", 1.0)
	if health <= 0 and not dead:
		enemy_die()
	return health

func enemy_die() -> void:
	dead = true
	set_texture(EnemyTexture.DEAD)
	
	await get_tree().create_timer(1.0).timeout
	
	die.emit()
	call_deferred("queue_free")


func _on_hit_area_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	hurting_player = true

func _on_hit_area_body_exited(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	hurting_player = false

func _on_attack_timeout() -> void:
	can_hit_player = true

func _on_detect_area_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	sees_player = true

func _on_detect_area_body_exited(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	sees_player = false
