extends CanvasLayer
# The sky above the port was the colour of a television, tuned
# to a dead channel.

func _ready() -> void:
	CameraController.paused_by_force = true

func _on_play_button_pressed() -> void:
	CameraController.paused_by_force = false
	ScreenTransition.change_scene("res://Levels/level_1.tscn")
