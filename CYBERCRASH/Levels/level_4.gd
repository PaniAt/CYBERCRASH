extends Level


func _process(delta: float) -> void:
	super._process(delta)
	
	$WinPortal/Texture.mesh.material.albedo_texture.noise.offset.x += delta * 60.0

func _on_detection_body_entered(body: Node3D) -> void:
	super._on_detection_body_entered(body)
	
	ScreenTransition.change_scene("res://Interfaces/win_scene.tscn")

func _on_platform_squash_body_entered(body: Node3D) -> void:
	if body is Player:
		body.damage(1000)
	elif body is Enemy:
		body.take_damage(1000)
