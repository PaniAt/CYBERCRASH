extends CanvasLayer
const SETTINGS_SCENE := preload("res://Interfaces/settings_menu.tscn")
const SAVE_FILE_PATH := "./CYBERCRASH_SAVE.txt"
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

func _on_save_quit_button_pressed() -> void:
	Settings.save_to_file(SAVE_FILE_PATH)
	_on_quit_button_pressed()

func _on_quit_button_pressed() -> void:
	get_tree().quit(0)

func _on_load_button_pressed() -> void:
	Settings.load_from_file(SAVE_FILE_PATH)
	_on_resume_button_pressed()
