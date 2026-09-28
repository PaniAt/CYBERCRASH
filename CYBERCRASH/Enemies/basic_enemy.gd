class_name BasicEnemy
extends Enemy

func take_damage(amount: int) -> int:
	velocity.y += amount / 15.0
	velocity.y = min(velocity.y, 10.0) # They go flying sometimes
	return super.take_damage(amount)

func _process(delta: float) -> void:
	super._process(delta)
	if health < (MAX_HEALTH / 2.0):
		speed = lerp(speed, MAX_SPEED * 2.0, delta)

func enemy_die() -> void:
	await super.enemy_die()
	
	if Settings.flashy_visuals:
		var div = global_position.distance_squared_to(Player.pos)
		div /= 360.0
		div += 0.9
		CameraController.camera_shake_time += 0.15 / div
		CameraController.camera_shake_power += 0.5 / div
		const SCENE := preload("res://Effects/blood_explosion.tscn")
		var explosion = SCENE.instantiate() as BloodExplosion
		explosion.position = position
		add_sibling(explosion)
