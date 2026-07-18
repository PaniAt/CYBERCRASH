extends CanvasLayer

var restarted := false

func _on_retry_button_pressed() -> void:
	if not restarted:
		ScreenTransition.change_scene(ScreenTransition.last_scene)
		Player.restart()
		restarted = true
