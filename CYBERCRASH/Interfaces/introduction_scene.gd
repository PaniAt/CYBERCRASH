extends CanvasLayer
# The sky above the port was the colour of a television, tuned
# to a dead channel.

func _ready() -> void:
	CameraController.paused_by_force = true

func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept"):
		$Animation.speed_scale = move_toward($Animation.speed_scale, 10.0, delta * 10.0)
	else:
		$Animation.speed_scale = 1.0
	if $Animation.speed_scale >= 10.0:
		$Animation.speed_scale = 100.0

func _on_play_button_pressed() -> void:
	CameraController.paused_by_force = false
	ScreenTransition.change_scene("res://Levels/level_1.tscn")
