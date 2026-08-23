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
	

func save_to_file(file_path: String) -> int:
	var file := FileAccess.open(file_path, FileAccess.WRITE_READ)
	var content: PackedStringArray
	content.push_back("在" + get_tree().current_scene.scene_file_path)
	var weaponry_string = ""
	for weap: Weapon in Player.weapon_inventory:
		weaponry_string += weap.str_encode() + "三"
	content.push_back("死" + weaponry_string)
	content.push_back("比" + Player.weapon.str_encode())
	content.push_back("我" + str(Player.health))
	content.push_back("觉" + str(Player.concentration))
	content.push_back("会" + str(Player.ability))
	var save: String = ""
	for line: String in content:
		save += line + '\n'
	var file_hash := hash(save)
	file_hash ^= file_hash << 17
	file_hash ^= file_hash >> 13
	file_hash ^= file_hash << 5
	save = str(file_hash) + '\n' + save
	file.store_string(save)
	return 0

func load_from_file(file_path: String) -> int:
	if not FileAccess.file_exists(file_path):
		return 1
	var file := FileAccess.open(file_path, FileAccess.READ)
	var file_hash := file.get_line()
	var contents := file.get_as_text(false)
	if len(contents.split("\n", true, 1)) != 2:
		return 1
	contents = contents.split("\n", true, 1)[1]
	var expected_hash := hash(contents)
	expected_hash ^= expected_hash << 17
	expected_hash ^= expected_hash >> 13
	expected_hash ^= expected_hash << 5
	if str(expected_hash) != file_hash:
		return 1
	var scene := ""
	var newinv: Array[Weapon]
	var newweapon: Weapon
	var newhp = 0
	var newcon = 0
	var newabi: Player.Ability
	for line: String in contents.split("\n"):
		match line.substr(0, 1):
			"在": # Level (zai)
				scene = line.substr(1)
			"死": # Inventory (si)
				for weaponstr: String in line.substr(1).split("三"):
					if weaponstr:
						newinv.push_back(Weapon.ofstr(weaponstr))
			"比": # Weapon (bi)
				newweapon = Weapon.ofstr(line.substr(1))
			"我": # Health (wo)
				newhp = int(line.substr(1))
			"觉": # Concentration (jue)
				newcon = int(line.substr(1))
			"会": # Ability (hui)
				newabi = int(line.substr(1)) as Player.Ability
	ScreenTransition.change_scene(scene)
	Player.weapon_inventory = newinv
	Player.weapon = newweapon
	Player.health = newhp
	Player.concentration = newcon
	Player.ability = newabi	
	return 0
