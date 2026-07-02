extends Node

const DEFAULT_CAMERA_SHAKE_POWER := 5.0
const DEFAULT_CAMERA_FOV := 75.0

var max_pitch := PI / 2.0
var max_move := 180.0
var mouse_sensitivity := 10.0
var mouse_smooth := 4.0
var camera_move := Vector3.ZERO
var camera_shake_time := 0.0
var camera_shake_power := DEFAULT_CAMERA_SHAKE_POWER
var fov_modifiers: Dictionary[StringName, Modifier] = {}
var internal_timer := 0.0
var paused := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	internal_timer += delta
	
	if Input.is_action_just_pressed("PAUSE"):
		if paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			paused = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			paused = true
	
	update_camera(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_move.x += -event.relative.x * mouse_sensitivity
		camera_move.y += -event.relative.y * mouse_sensitivity
		if max_move:
			var limit = max_move * mouse_sensitivity
			camera_move.x = clampf(camera_move.x, -limit, limit)
			camera_move.y = clampf(camera_move.y, -limit, limit)

func update_camera(delta: float) -> void:
	var camera := get_camera()
	if not camera:
		return	# No camera exists, exit before errors happen.
	camera.rotation_degrees.x += camera_move.y * delta
	if max_pitch:
		camera.rotation.x = clampf(camera.rotation.x, -max_pitch, max_pitch)
	camera.rotation_degrees.y += camera_move.x * delta
	camera.fov = DEFAULT_CAMERA_FOV
	
	calculate_fov(delta, camera)
	
	camera_move /= mouse_smooth
	
	if camera_shake_time > 0.0:
		camera_shake_time -= delta
		var mult := camera_shake_power * delta
		camera.h_offset += sin(internal_timer * 60) * mult
		camera.v_offset += cos(internal_timer * 60) * mult
	else:
		camera_shake_time = 0.0
		camera_shake_power = DEFAULT_CAMERA_SHAKE_POWER
		camera.h_offset = move_toward(camera.h_offset, 0, delta * 60)
		camera.v_offset = move_toward(camera.v_offset, 0, delta * 60)
	
	camera_shake_power = move_toward(camera_shake_power, DEFAULT_CAMERA_SHAKE_POWER, delta)

func calculate_fov(delta: float, camera: Camera3D) -> void:
	for key: StringName in fov_modifiers:
		var modifier = fov_modifiers[key]
		camera.fov += modifier.get_strength()
		if modifier.duration >= 0:
			modifier.duration -= delta
		else:
			fov_modifiers.erase(key)
func has_fov_mod(key: StringName) -> bool:
	return fov_modifiers.has(key)
func get_fov_mod(key: StringName) -> Modifier:
	return fov_modifiers.get(key)
func del_fov_mod(key: StringName) -> bool:
	return fov_modifiers.erase(key)
func set_fov_mod(key: StringName, modifier: Modifier) -> bool:
	return fov_modifiers.set(key, modifier)

func get_camera() -> Camera3D:
	return get_viewport().get_camera_3d()

## Returns the camera's direction in radians
func get_camera_direction(deg := false) -> Vector3:
	if get_camera():
		if deg:
			return get_camera().rotation_degrees
		else:
			return get_camera().rotation
	else:
		return Vector3.ZERO
