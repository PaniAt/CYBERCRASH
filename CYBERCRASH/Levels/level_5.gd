extends Level

func _process(delta: float) -> void:
	super._process(delta)
	
	$WinPortal/Texture.mesh.material.albedo_texture.noise.offset.x += delta * 60.0

func _on_detection_body_entered(body: Node3D) -> void:
	super._on_detection_body_entered(body)
	
	ScreenTransition.change_scene("res://Levels/level_6.tscn")

func _on_death_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	body.damage(1000)

func _on_weapon_console_opened() -> void:
	$Geometry/WeaponConsole.usable = false
	var tweener = get_tree().create_tween()
	$Geometry/WeaponConsole.collision_layer = 0
	tweener.tween_property($Geometry/WeaponConsole, "global_position", Vector3(13.0, 36.5, -3.0), 3.0)
	await tweener.finished
	$Geometry/WeaponConsole.global_position.y = -999999.9
