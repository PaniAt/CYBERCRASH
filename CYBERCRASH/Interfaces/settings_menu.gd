extends CanvasLayer
# NOTE: This is the code for the settings menu itself, and
# NOTE: is not where the variables for the settings them-
# NOTE: selves are stored. See 'res://settings.gd'

signal exit()

var selecting_key := ""

func _ready() -> void:
	%AimAssistSlider.value = Settings.aim_assist
	%GammaSlider.value = Settings.gamma

func _process(_delta: float) -> void:
	update_control_button_text()

func _unhandled_key_input(event: InputEvent) -> void:
	# I really love assertions
	assert(event is InputEventKey, "Expected InputEventKey, received: " + str(event))
	
	if selecting_key != "":
		if event.keycode == KEY_ESCAPE:
			event.keycode = Settings.DEFAULT_KEYS[selecting_key]
			CameraController.ignore_next_unpause = true
		Settings.key_controls[selecting_key] = event.keycode
		Settings.update_keybinds()
		selecting_key = ""

func update_control_button_text() -> void:
	# This code carefully relies upon the button name being
	# the same (case insensitive) to both the one supplied
	# Settings and the InputMap
	var name_regex = RegEx.create_from_string("\\((?<name>\\w+)\\)")
	for button: Button in $Main/Settings/Controls.get_children():
		if selecting_key == button.name.to_upper():
			button.text = button.name + ": ..."
		else:
			# What the evilness?
			var key = InputMap.action_get_events(button.name.to_upper())[0]
			var result = name_regex.search(str(key))
			var keycode: String
			if result:
				keycode = result.get_string("name")
			else:
				keycode = "?"
			button.text = button.name + ": " + keycode

func _on_back_button_pressed() -> void:
	call_deferred("queue_free")
	exit.emit()

func _on_aim_assist_slider_value_changed(value: float) -> void:
	Settings.aim_assist = value

func _on_gamma_slider_value_changed(value: float) -> void:
	Settings.gamma = value
	if CameraController.has_world_environment:
		CameraController.world_environment.environment.tonemap_exposure = value


# Key rebinding signal listeners
func _on_forwards_pressed() -> void:
	selecting_key = "FORWARDS"
func _on_left_pressed() -> void:
	selecting_key = "LEFT"
func _on_backwards_pressed() -> void:
	selecting_key = "BACKWARDS"
func _on_right_pressed() -> void:
	selecting_key = "RIGHT"
func _on_jump_pressed() -> void:
	selecting_key = "JUMP"
func _on_reload_pressed() -> void:
	selecting_key = "RELOAD"
func _on_crouch_pressed() -> void:
	selecting_key = "CROUCH"
func _on_sprint_pressed() -> void:
	selecting_key = "SPRINT"
func _on_item_wheel_pressed() -> void:
	selecting_key = "ITEMWHEEL"

func _on_visuals_button_toggled(toggled_on: bool) -> void:
	Settings.flashy_visuals = toggled_on
