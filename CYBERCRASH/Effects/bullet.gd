class_name Bullet
extends CharacterBody3D
# For the sentry enemy's bullets

var initial_velocity: Vector3
var power: int
var collided := false
var internal_timer := 0.0
var death_time := 5.0

func _process(delta: float) -> void:
	internal_timer += delta
	if not collided:
		velocity = initial_velocity
		move_and_slide()
	else:
		velocity = Vector3.ZERO
	if internal_timer >= death_time:
		call_deferred("queue_free")

func _on_detect_area_body_entered(body: Node3D) -> void:
	collided = true
	
	if body is Player:
		body.damage(power)
	else:
		pass
	
	call_deferred("queue_free")
