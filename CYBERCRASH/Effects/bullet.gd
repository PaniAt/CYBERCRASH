class_name Bullet
extends CharacterBody3D
# For the sentry enemy's bullets

var initial_velocity: Vector3 ## Initial bullet velocity
var power: int ## The damage the bullet deals
var collided := false ## Whether it has collided with something
var internal_timer := 0.0 ## Self-descriptive
var death_time := 5.0 ## Time until the bullet naturally despawns

func _process(delta: float) -> void:
	internal_timer += delta
	# Got to make a move to a town that is right for me
	if not collided:
		velocity = initial_velocity
		move_and_slide()
	else:
		velocity = Vector3.ZERO
	if internal_timer >= death_time:
		call_deferred("queue_free")

## The bullet hit the player
func _on_detect_area_body_entered(body: Node3D) -> void:
	collided = true
	
	if body is Player:
		body.damage(power)
	else:
		pass
	
	call_deferred("queue_free")
