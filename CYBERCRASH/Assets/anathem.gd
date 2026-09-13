extends Node3D

signal chime() ## Emitted when the hands align

@export var moving := false
var chimed := false

func _process(delta: float) -> void:
	var real_delta := delta
	if not moving:
		delta *= 0.0
	
	# SOme evilness (look ma! no timers!)
	$Clock/Face1/Hand1.rotation_degrees.y -= delta * 6.0
	$Clock/Face1/Hand2.rotation_degrees.y -= delta
	$Clock/Face1/Hand3.rotation_degrees.y -= delta / 6.0
	$Clock/Face1/Hand4.rotation_degrees.y += delta * 60.0
	
	# Check if all hands are (roughly) aligned
	if (
		abs(angle_difference($Clock/Face1/Hand1.rotation.y, $Clock/Face1/Hand2.rotation.y)) < PI / 32 and
		abs(angle_difference($Clock/Face1/Hand1.rotation.y, $Clock/Face1/Hand3.rotation.y)) < PI / 32
		):
		$Clock/Face1/Hand1.rotation.y = lerp_angle($Clock/Face1/Hand1.rotation.y, 0.0, real_delta)
		$Clock/Face1/Hand2.rotation.y = lerp_angle($Clock/Face1/Hand2.rotation.y, $Clock/Face1/Hand1.rotation.y, real_delta)
		$Clock/Face1/Hand3.rotation.y = lerp_angle($Clock/Face1/Hand3.rotation.y, $Clock/Face1/Hand1.rotation.y, real_delta)
		$Clock/Face1/Hand4.rotation.y = lerp_angle($Clock/Face1/Hand4.rotation.y, $Clock/Face1/Hand1.rotation.y, real_delta)
		moving = false
		if not chimed:
			chime.emit()
			chimed = true
