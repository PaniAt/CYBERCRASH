extends Level


func _process(delta: float) -> void:
	super._process(delta)
	
	$WinPortal/Texture.mesh.material.albedo_texture.noise.offset.x += delta * 60.0

func _on_detection_body_entered(body: Node3D) -> void:
	super._on_detection_body_entered(body)
	
	# Switch to the proper ability selection interface
	var scn := "Levels/level_5"
	
	match(Player.ability):
		Player.Ability.GLITCH:
			scn = "Interfaces/glitch_ability_selector"
		Player.Ability.XRAY:
			scn = "Interfaces/xray_ability_selector"
		Player.Ability.AGILITY:
			scn = "Interfaces/agility_ability_selector"

	ScreenTransition.change_scene("res://" + scn + ".tscn")

func _on_platform_squash_body_entered(body: Node3D) -> void:
	if body is Player:
		body.damage(1000)
	elif body is Enemy:
		body.take_damage(1000)
