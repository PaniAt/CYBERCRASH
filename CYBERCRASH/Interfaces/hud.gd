extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Main/HealthBar.hide()
	for player: Player in get_tree().get_nodes_in_group("Players"):
		$Main/HealthBar.show()
		player.connect("hurt", healthbar_damage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	manage_crosshair(delta)
	manage_healthbar(delta)

func manage_crosshair(delta: float) -> void:
	if Player.hit_something > 0.0:
		var hitmarker: TextureRect = $Main/Crosshair/Hitmarker
		hitmarker.modulate.a = Player.hit_something
		hitmarker.show()
		Player.hit_something -= delta * 4.0
	else:
		Player.hit_something = 0.0
		$Main/Crosshair/Hitmarker.hide()

func manage_healthbar(delta: float) -> void:
	var bar: TextureProgressBar = $Main/HealthBar/Bar
	var percent := Player.health * 100.0 / Player.MAX_HEALTH
	bar.value = lerpf(bar.value, percent, delta * 12.0)
	bar.material.set_shader_parameter("ratio", bar.value / bar.max_value)
	bar.material.set_shader_parameter("progress", 
		lerpf(
			bar.material.get_shader_parameter("progress"),
			0.0, delta * 12.0)
	)

func healthbar_damage(_amount: int, _health: int) -> void:
	var mat = $Main/HealthBar/Bar.material
	mat.set_shader_parameter("progress", mat.get_shader_parameter(
			"progress"
		) + 0.5
	)
	
