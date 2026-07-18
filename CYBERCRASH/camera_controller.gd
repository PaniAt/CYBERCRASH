extends Node

const DEFAULT_CAMERA_SHAKE_POWER := 5.0
const DEFAULT_CAMERA_FOV := 75.0
const PAUSE_SCENE = preload("res://Interfaces/pause_menu.tscn")

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
var paused_by_force := false
var ignore_next_unpause := false
var pause_menu: CanvasLayer
var has_world_environment: bool
var world_environment: WorldEnvironment
var free_mouse := false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	process_mode = Node.PROCESS_MODE_ALWAYS # Никогда не умереть

func _process(delta: float) -> void:
	if ScreenTransition.changing_scene:
		paused = false
		get_tree().paused = paused
	elif paused_by_force:
		paused = true
		#get_tree().paused = paused
	elif ignore_next_unpause:
		ignore_next_unpause = false
	elif Input.is_action_just_pressed("PAUSE"):
		if paused:
			Engine.time_scale = 1.0
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			paused = false
			
			pause_menu.call_deferred("queue_free")
		else:
			Engine.time_scale = 0.0
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			paused = true
			
			pause_menu = PAUSE_SCENE.instantiate() as CanvasLayer
			add_child(pause_menu)
		get_tree().paused = paused
	
	if paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		internal_timer += delta
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
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return	# No camera exists, exit before errors happen.
	elif free_mouse:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = int(not paused) * 2 as Input.MouseMode
	camera.rotation_degrees.x += camera_move.y * delta
	if max_pitch:
		camera.rotation.x = clampf(camera.rotation.x, -max_pitch, max_pitch)
	camera.rotation_degrees.y += camera_move.x * delta
	
	calculate_fov(delta, camera)
	
	calculate_aim_assist(delta, camera)
	
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
	var target_fov := DEFAULT_CAMERA_FOV
	
	for key: StringName in fov_modifiers:
		var modifier = fov_modifiers[key]
		target_fov += modifier.get_strength()
		if modifier.duration >= 0:
			modifier.duration -= delta
		else:
			fov_modifiers.erase(key)
	
	# Tiny bit more interp, makes it so much cleaner
	camera.fov = move_toward(camera.fov, target_fov, delta * 30.0)

func has_fov_mod(key: StringName) -> bool:
	return fov_modifiers.has(key)
func get_fov_mod(key: StringName) -> Modifier:
	return fov_modifiers.get(key)
func del_fov_mod(key: StringName) -> bool:
	return fov_modifiers.erase(key)
func set_fov_mod(key: StringName, modifier: Modifier) -> bool:
	return fov_modifiers.set(key, modifier)

func calculate_aim_assist(delta: float, camera: Camera3D) -> void:
	if Settings.aim_assist == 0.0:
		return
	
	var closest: Enemy
	var target_dir: Vector2
	var ang_dist: float
	var dist := 4096.0
	for enemy: Enemy in get_tree().get_nodes_in_group(&"Enemies"):
		target_dir = Math.atan3(Player.pos - enemy.global_position + Vector3(0.0, 1.0, 0.0))
		ang_dist = Vector2(
			angle_difference(camera.rotation.y, target_dir.x),
			angle_difference(camera.rotation.x, target_dir.y)
			).length_squared()
		#if (enemy.global_position - Player.pos).length_squared() < dist and not enemy.dead and abs(enemy.global_position.y - Player.pos.y) < 16.0:
			#dist = (enemy.global_position - Player.pos).length_squared()
			#closest = enemy
		if ang_dist < dist and not enemy.dead:
			dist = ang_dist
			closest = enemy
	
	if not closest:
		return
	
	target_dir = Math.atan3(Player.pos - (closest.global_position - Vector3(0.0, 1.0, 0.0)))
	#ang_dist = angle_difference(get_camera_direction().y, target_dir.x)
	#if abs(rad_to_deg(ang_dist)) <= Settings.aim_assist:
	if dist <= deg_to_rad(Settings.aim_assist) ** 2:
		camera.rotation.y = lerp_angle(camera.rotation.y, target_dir.x, delta * 12.0)
		camera.rotation.x = lerp_angle(camera.rotation.x, target_dir.y, delta * 12.0)

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

## Attempts to unpause the game, returning whether
## the operation was successful
func unpause() -> bool:
	if paused_by_force:
		return false
	
	paused = false
	Engine.time_scale = 1.0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false
	
	return true
