extends Level

var intro_cutscene_played := false

func _ready() -> void:
	super._ready();
	# This damn things do not want to behave
	$Geometry/Block1.global_position = Vector3(0.0, 28.5, -76.0)
	$Geometry/Block2.global_position = Vector3(80.0, 28.5, -40.0)

func _on_cutscene_trigger_body_entered(_body: Node3D) -> void:
	if intro_cutscene_played: return # Only play it once.
	CameraController.paused_by_force = true
	$HUD/CutsceneOverlay.show()
	$Geometry/Block1/Movement.play(&"move")
	$Geometry/Block2/Movement.play(&"move_2")
	$Animation.play(&"anathem_intro")
	intro_cutscene_played = true

func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"anathem_intro":
		#Engine.time_scale = 30.0
		CameraController.paused_by_force = false
		CameraController.paused = false
		CameraController.always_shake = false
		$HUD/CutsceneOverlay.hide()
	elif anim_name == &"anathem_chime":
		$Player.damage(1000)
	elif anim_name == &"win":
		ScreenTransition.change_scene("res://Interfaces/win_scene.tscn")

## For animations shaking the camera
func shake_camera(power: float, time: float) -> void:
	CameraController.camera_shake_power = power
	CameraController.camera_shake_time = time
	CameraController.always_shake = true

func block_hit_entity(body: Node3D, velo: Vector3) -> void:
	assert(body is CharacterBody3D, "Expected CharacterBody3D, received: " + str(body))
	
	# body dies either way
	if body is Player:
		body.velocity = -velo * 3072.0
		body.damage(Player.MAX_HEALTH)
	elif body is Enemy:
		body.velocity = -velo * 1024.0
		body.velocity.y += 4.0
		body.take_damage(body.MAX_HEALTH)

# Probably not a good idea for me to repeat myself here.
# But I don't care yet!
func _on_block_1_detector_body_entered(body: Node3D) -> void:
	var velo: Vector3
	velo = body.global_position
	velo = velo.direction_to($Geometry/Block1.global_position)
	velo.y = -0.01
	block_hit_entity(body, velo)

func _on_block_2_detector_body_entered(body: Node3D) -> void:
	var velo: Vector3
	velo = body.global_position
	velo = velo.direction_to($Geometry/Block2.global_position)
	velo.y = -0.01
	block_hit_entity(body, velo)

func _on_anathem_chime() -> void:
	CameraController.paused_by_force = true
	$HUD/CutsceneOverlay.show()
	$Animation.play(&"anathem_chime")
	# Tween stuff for the dynamic falling animation
	var tween := get_tree().create_tween()
	var target_dir := Math.atan2d($Geometry/Anathem.global_position, Player.pos) + PI
	if target_dir < PI:
		$Geometry/Anathem.rotation = Vector3.ZERO
	tween.tween_property($Geometry/Anathem, "rotation", Vector3($Geometry/Anathem.rotation.x, target_dir, $Geometry/Anathem.rotation.z), 3.0)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property($Geometry/Anathem, "rotation", Vector3(PI / 2.0, $Geometry/Anathem.rotation.y, $Geometry/Anathem.rotation.z), 2.0)

func _on_death_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	body.damage(1000)


func _on_server_die() -> void:
	$Geometry/Block1/Movement.speed_scale = 0.0
	$Geometry/Block2/Movement.speed_scale = 0.0
	$Animation.play("win")
