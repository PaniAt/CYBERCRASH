extends CanvasLayer

func _ready() -> void:
	CameraController.paused_by_force = true

func _on_play_button_pressed() -> void:
	CameraController.paused_by_force = false
	ScreenTransition.change_scene("res://Levels/level_1.tscn")
