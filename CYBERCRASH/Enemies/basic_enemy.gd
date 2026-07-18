class_name BasicEnemy
extends Enemy

func take_damage(amount: int) -> int:
	velocity.y += amount / 15.0
	return super.take_damage(amount)

func _process(delta: float) -> void:
	super._process(delta)
	if health < (MAX_HEALTH / 2.0):
		speed = lerp(speed, MAX_SPEED * 2.0, delta)

func enemy_die() -> void:
	await super.enemy_die()
	
	if Settings.flashy_visuals:
		CameraController.camera_shake_time += 0.15
		CameraController.camera_shake_power += 0.5
		const SCENE := preload("res://Effects/blood_explosion.tscn")
		var explosion = SCENE.instantiate() as BloodExplosion
		explosion.position = position
		add_sibling(explosion)
