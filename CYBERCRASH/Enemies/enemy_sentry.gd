class_name SentryEnemy
extends Enemy

const BULLET_SCENE := preload("res://Effects/bullet.tscn")

func enemy_movement(delta: float) -> void:
	super.enemy_movement(delta)
	
	$OtherTextures.rotation = -rotation

func take_damage(amount: int) -> int:
	velocity = Vector3.ZERO
	if amount > 5:
		var target = Math.atan2d(Player.pos, global_position)
		target -= PI / 2.0
		rotation.y = target
		shoot_at_player()
	return super.take_damage(amount)

func try_hitting_player() -> void:
	if not hurting_player or not can_hit_player:
		return
	
	can_hit_player = false
	$Timers/Attack.start()
	
	shoot_at_player()

func shoot_at_player() -> void:
	var bullet := BULLET_SCENE.instantiate() as Bullet
	bullet.power = strength
	bullet.initial_velocity = global_position.direction_to(Player.pos) * 75.0 * Enemy.time_scale
	add_sibling(bullet)
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation

func enemy_die() -> void:
	await super.enemy_die()
	
	if Settings.flashy_visuals:
		CameraController.camera_shake_time += 0.25
		CameraController.camera_shake_power += 1.0
		const SCENE := preload("res://Effects/blood_explosion.tscn")
		var explosion = SCENE.instantiate() as BloodExplosion
		explosion.scale *= 2.0
		explosion.position = position
		add_sibling(explosion)
