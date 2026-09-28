extends CanvasLayer

var restarted := false

## Not giving up I see... How curious
func _on_retry_button_pressed() -> void:
	if not restarted:
		ScreenTransition.change_scene(ScreenTransition.last_scene)
		Player.restart()
		restarted = true
