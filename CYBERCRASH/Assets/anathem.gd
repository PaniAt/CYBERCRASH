extends Node3D

@export var moving := false

func _process(delta: float) -> void:
	if not moving:
		delta *= 0.0
	$Clock/Face1/Hand1.rotation_degrees.y -= delta * 6.0
	$Clock/Face1/Hand2.rotation_degrees.y -= delta
	$Clock/Face1/Hand3.rotation_degrees.y -= delta / 6.0
	$Clock/Face1/Hand4.rotation_degrees.y += delta * 60.0
	
	if (
		abs(angle_difference($Clock/Face1/Hand1.rotation.y, $Clock/Face1/Hand2.rotation.y)) < PI / 32 and
		abs(angle_difference($Clock/Face1/Hand1.rotation.y, $Clock/Face1/Hand3.rotation.y)) < PI / 32
		):
		moving = false
