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
