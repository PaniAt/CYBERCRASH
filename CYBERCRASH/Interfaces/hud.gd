extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Main/Bars.hide()
	for player: Player in get_tree().get_nodes_in_group("Players"):
		$Main/Bars.show()
		player.connect("hurt", healthbar_damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	manage_crosshair(delta)
	manage_bars(delta)
	
	if not Settings.flashy_visuals:
		$Main/Flash.hide()
	
	$Main/Weapon/Display.texture = Player.weapon.texture
	$Main/Weapon/Ammo.text = Player.weapon.ammo_text()

func manage_crosshair(delta: float) -> void:
	if Player.hit_something > 0.0:
		var hitmarker: TextureRect = $Main/Crosshair/Hitmarker
		hitmarker.modulate.a = Player.hit_something
		hitmarker.show()
		Player.hit_something -= delta * 4.0
	else:
		Player.hit_something = 0.0
		$Main/Crosshair/Hitmarker.hide()

func manage_bars(delta: float) -> void:
	# Health bar
	var bar: TextureProgressBar = $Main/Bars/Health
	var percent := Player.health * 100.0 / Player.MAX_HEALTH
	bar.value = lerpf(bar.value, percent, delta * 12.0)
	$Main/Bars/Health/Text.text = "HP: " + fsi(bar.value) + " / " + fsi(bar.max_value)
	bar.material.set_shader_parameter("ratio", bar.value / bar.max_value)
	bar.material.set_shader_parameter("progress", 
		lerpf(
			bar.material.get_shader_parameter("progress"),
			0.0, delta * 12.0)
	)
	$Main/Flash.color.a = lerpf($Main/Flash.color.a, 0.0, delta * 12.0)
	
	# Sprint bar
	bar = $Main/Bars/Sprint
	percent = Player.sprint * 100.0 / Player.MAX_SPRINT
	bar.value = percent
	
	# Concentration bar
	bar = $Main/Bars/Concentration
	if Player.ability != Player.Ability.NONE:
		bar.show()
		percent = Player.concentration * 100.0 / Player.MAX_CONCENTRATION
		bar.value = lerpf(bar.value, percent, delta * 12.0)
		$Main/Bars/Concentration/Text.text = "Concentration: " + fsi(bar.value) + " / " + fsi(bar.max_value)
	else:
		bar.hide()

## "Float to string integer", rounds floats the nearest
## integer (not floored) and then stringifies them
func fsi(x: float) -> String:
	return str(int(round(x)))

func healthbar_damage(amount: int, _health: int) -> void:
	var mat = $Main/Bars/Health.material
	mat.set_shader_parameter("progress", mat.get_shader_parameter(
			"progress"
		) + 0.5
	)
	var flash := 1.0 * amount / Player.MAX_HEALTH
	$Main/Flash.color = Color(1.0, 0.0, 0.0, flash)
