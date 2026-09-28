# No class_name because that's just too much
extends Level

var weapon_console_opened := false
var hint_fade_timer := 0.0

func _ready() -> void:
	$HUD/HintDisplay/Text.horizontal_alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_CENTER

func _process(delta: float) -> void:
	super._process(delta)
	$WinPortal/Texture.mesh.material.albedo_texture.noise.offset.x += delta * 60.0
	if hint_fade_timer > 0.0:
		$HUD/HintDisplay.show()
		if hint_fade_timer < 1.0:
			$HUD/HintDisplay.modulate.a = hint_fade_timer
		hint_fade_timer -= delta
	else:
		hint_fade_timer = 0.0
		$HUD/HintDisplay.modulate.a = 1.0
		$HUD/HintDisplay.hide()
		

func _on_detection_body_entered(body: Node3D) -> void:
	super._on_detection_body_entered(body)
	
	ScreenTransition.change_scene("res://Levels/level_2.tscn")


func _on_death_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	body.damage(1000)


func _on_notice_area_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	for enemy: Enemy in get_tree().get_nodes_in_group("Enemies"):
		#enemy.always_sees_player = true
		# I made this easier due to trialling
		pass


func _on_hint_1_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected Player: " + str(body))
	hint_fade_timer = 999999.0
	if not weapon_console_opened:
		$HUD/HintDisplay.text = "Walk into the weapon console in order to customise your weapon"
	else:
		$HUD/HintDisplay.text = "You can use the number keys to select a weapon, or press 'I' to open your inventory"
	
	$HUD/HintDisplay.reload()
	$HUD/HintDisplay.start()

func _on_weapon_console_opened() -> void:
	weapon_console_opened = true
	$Geometry/WeaponConsole.usable = false
	var tweener = get_tree().create_tween()
	$Geometry/WeaponConsole.collision_layer = 0
	tweener.tween_property($Geometry/WeaponConsole, "global_position", Vector3(13.0, 36.5, -3.0), 3.0)
	await tweener.finished
	$Geometry/WeaponConsole.global_position.y = -999999.9

func _on_hint_display_finished() -> void:
	hint_fade_timer = 4.0
