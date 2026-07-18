extends Node
# NOTE: This is to store the game settings, not the code
# NOTE: for the settings menu. For that, you need to
# NOTE: see 'res://Interfaces/settings_menu.gd'

const DEFAULT_KEYS: Dictionary[StringName, Key] = {
	&"FORWARDS": KEY_W,
	&"LEFT": KEY_A,
	&"BACKWARDS": KEY_S,
	&"RIGHT": KEY_D,
	&"JUMP": KEY_SPACE,
	&"SPRINT": KEY_SHIFT,
	&"CROUCH": KEY_C,
	&"RELOAD": KEY_R,
	&"ITEMWHEEL": KEY_I
}

var gamma := 1.0
var aim_assist := 0.0
var key_controls: Dictionary[StringName, Key] = {
	&"FORWARDS": KEY_W,
	&"LEFT": KEY_A,
	&"BACKWARDS": KEY_S,
	&"RIGHT": KEY_D,
	&"JUMP": KEY_SPACE,
	&"SPRINT": KEY_SHIFT,
	&"CROUCH": KEY_C,
	&"RELOAD": KEY_R,
	&"ITEMWHEEL": KEY_I,
}
var flashy_visuals := true


## Updates all of the InputMappings
func update_keybinds() -> void:
	var key_evt: InputEvent
	
	for keybind in key_controls:
		key_evt = InputEventKey.new()
		key_evt.keycode = key_controls[keybind]
		InputMap.action_erase_events(keybind)
		InputMap.action_add_event(keybind, key_evt)
	
