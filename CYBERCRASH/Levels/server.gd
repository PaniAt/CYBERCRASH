class_name ServerBoss
extends StaticBody3D

const MAX_HEALTH := 16384 # 2 ** 14

signal die()

@export var active := false ## Basically just has the intro run

var health := MAX_HEALTH
var dead := false

var internal_timer := 0.0
var last_spawn := 0.0
var max_spawn_time := 10.0

func _process(delta: float) -> void:
	if CameraController.paused: return
	tick_damage_flash(delta)
	
	if not active or dead: return
	delta *= Enemy.time_scale
	internal_timer += delta

	try_summon()

## Formula created after about 5 minutes of tinkering on Desmos.
## W(t, M) = (e^((t/M)^5) - 1) / (e - 1)
## where t is the time since the last spawn and M is the max
## time between spawns.
## Returns a value [0, 1]
func sweight(t_d: float, t_M: float) -> float:
	# 1.718281828459045 = e - 1
	return (exp((t_d / t_M) ** 5.0) - 1.0) / 1.718281828459045;

func try_summon() -> void:
	var time := internal_timer - last_spawn
	var prob = sweight(time, max_spawn_time)
	if randf() < prob:
		const BASIC_SCENE := preload("res://Enemies/basic_enemy.tscn")
		const STRONG_SCENE = preload("res://Enemies/enemy_strengthened.tscn")
		const SENTRY_SCENE = preload("res://Enemies/enemy_sentry.tscn")
		# I could provide reasons why these ranges are used via
		# analysing the compounding probability, but instead:
		# The proof is left as an exercise to the reader.
		# (insert glimmering sparkle effects around text)
		if time < 5.0:
			summon_enemy(BASIC_SCENE)
		elif time < 6.0:
			summon_enemy(STRONG_SCENE)
		else:
			summon_enemy(SENTRY_SCENE)
		last_spawn = internal_timer

func summon_enemy(scene: PackedScene) -> void:
	var enemy := scene.instantiate() as Enemy
	add_sibling(enemy)
	enemy.global_position = self.global_position + Vector3(0.0, 16.0, 0.0)
	enemy.global_position = Math.towards(enemy.global_position, Player.pos, 6.0)
	enemy.velocity = enemy.global_position.direction_to(Player.pos) * (Player.pos - enemy.global_position).length() * 8.0
	enemy.velocity.y = abs(enemy.velocity.y) / 64.0
	enemy.always_sees_player = true

func tick_damage_flash(delta: float) -> void:
	#var healthmesh: Mesh = $HealthBar/Health.mesh
	#var target = (2.0 * self.health) / MAX_HEALTH
	#healthmesh.size.x = lerpf(healthmesh.size.x, target, delta * 30.0)
	var tex := $Texture1
	if tex.get_instance_shader_parameter("progress"):
		var dmg: float
		dmg = tex.get_instance_shader_parameter("progress")
		dmg -= delta * 10.0
		dmg = clampf(dmg, 0.0, 1.0)
		tex.set_instance_shader_parameter("progress", dmg)
	tex = $Texture2
	if tex.get_instance_shader_parameter("progress"):
		var dmg: float
		dmg = tex.get_instance_shader_parameter("progress")
		dmg -= delta * 10.0
		dmg = clampf(dmg, 0.0, 1.0)
		tex.set_instance_shader_parameter("progress", dmg)

func take_damage(amount: int) -> int:
	health = max(health - amount, 0)
	$Texture1.set_instance_shader_parameter("progress", 1.0)
	$Texture2.set_instance_shader_parameter("progress", 1.0)
	
	if health <= 0 and not dead:
		server_die()
	
	return health

func server_die() -> void:
	dead = true
	collision_layer = 0 # No more collisions
	CameraController.camera_shake_time = 2.25
	CameraController.camera_shake_power = 1.0
	
	var tween := get_tree().create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK) # possible: spring, back, circ
	tween.tween_property(self, "rotation", Vector3(PI / 2.0, 0.0, 0.0), 2.0)
	
	await get_tree().create_timer(2.0).timeout
	CameraController.camera_shake_power = 16.0
	
	await get_tree().create_timer(2.0).timeout
	die.emit()
	call_deferred("queue_free")
	
	if Settings.flashy_visuals:
		CameraController.camera_shake_time += 0.25
		CameraController.camera_shake_power += 16.0
		const SCENE := preload("res://Effects/blood_explosion.tscn")
		for i in range(8):
			var explosion = SCENE.instantiate() as BloodExplosion
			explosion.scale *= i
			explosion.position = position
			add_sibling(explosion)
