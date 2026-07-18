extends Level

func _process(delta: float) -> void:
	super._process(delta)
	
	$WinPortal/Texture.mesh.material.albedo_texture.noise.offset.x += delta * 60.0

func _on_detection_body_entered(body: Node3D) -> void:
	super._on_detection_body_entered(body)
	
	ScreenTransition.change_scene("res://Levels/level_4.tscn")


func _on_notice_area_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	for enemy: Enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.always_sees_player = true
		enemy.speed *= 1.5
