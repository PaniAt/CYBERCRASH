extends CanvasLayer
const SETTINGS_SCENE := preload("res://Interfaces/settings_menu.tscn")
var settings_menu: CanvasLayer

func _on_resume_button_pressed() -> void:
	if CameraController.unpause():
		call_deferred("queue_free")

func _on_settings_button_pressed() -> void:
	hide()
	settings_menu = SETTINGS_SCENE.instantiate() as CanvasLayer
	add_child(settings_menu)
	settings_menu.connect(&"exit", _on_settings_menu_exit)

func _on_settings_menu_exit() -> void:
	show()
