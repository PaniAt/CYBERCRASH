extends Node3D

func _process(delta: float) -> void:
	#$Geometry/Floor1/Texture.mesh.material.uv1_offset.x += delta
	# Warning? No thanks!
	var cringewarning = delta
	delta = cringewarning
	pass

func _on_detect_body_entered(_body: Node3D) -> void:
	ScreenTransition.change_scene("res://Interfaces/win_scene.tscn")
