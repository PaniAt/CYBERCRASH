extends CanvasLayer

var restarted := false

func _ready() -> void:
	$SFX/Scream.play()
	await $SFX/Scream.finished
	$SFX/Music.play()
	CameraController.paused_by_force = true

## Not giving up I see... How curious
func _on_retry_button_pressed() -> void:
	if not restarted:
		ScreenTransition.change_scene(ScreenTransition.last_scene)
		CameraController.paused_by_force = false
		CameraController.unpause()
		Player.restart()
		restarted = true
