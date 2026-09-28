class_name WeaponCustomisationScreen
extends CanvasLayer

signal exit()

## Gun textures
const TEXTURES: Array[CompressedTexture2D] = [
	preload("res://GFX/GunTextures/pickup_pistol.png"),
	preload("res://GFX/GunTextures/pickup_rifle.png"),
	preload("res://GFX/GunTextures/pickup_shotgun.png"),
	preload("res://GFX/GunTextures/pickup_crossbow.png"),
]

## [0] - Damage, [1] - Clip, [2] - Firespeed, [3] - Reload
## [n][0] - Minimum, [n][1] - Maximum
const RANGES: Dictionary[String, Array] = {
	"PISTOL" = [[10.0, 25.0], [2.0, 3.0], [0.3, 0.5], [0.7, 1.1]],
	"RIFLE" = [[10.0, 20.0], [3.0, 5.0], [0.2, 0.4], [0.9, 1.5]],
	"SHOTGUN" = [[30.0, 40.0], [1.0, 2.0], [0.6, 0.6], [2.0, 2.5]],
	"CROSSBOW" = [[70.0, 80.0], [1.0, 1.0], [1.0, 1.0], [4.0, 5.0]],
}

# TTK CALCULATIONS
# ----------------
# min TTK calculations for (optimal) weapons on easy enemy (HP = 40)
# Pistol: 0.3s (2x 20-damage shots, clip size of 2)
# Rifle: 0.4s (2x 20-damage shots, clip size of 2)
# Shotgun: 0.0s (1x 40-damage shot, clip size of 1)
# Crossbow: 0.0s (1x 50-damage shot)
#
# min TTK calculations for (optimal) weapons on hard enemy (HP = 80)
# Pistol: 1.3s (4x 25-damage shots, clip size of 3)
# Rifle: 0.8s (4x 20-damage shots, clip size of 4)
# Shotgun: 0.6s (2x 40-damage shots, clip size of 2)
# Crossbow: 0.0s (1x 80-damage shots)
#
# min TTK calculations for (optimal) weapons on 2x hard enemies (HP = 160)
# Pistol: 3.2s (8x 25-damage shots, clip size of 3)
# Rifle: 2.3s (8x 20-damage shots, clip size of 5)
# Shotgun: 3.2s (4x 40-damage shots, clip size of 2)
# Crossbow: 4.0s (2x 80-damage shots)
# ----------------
# From this I can conclude the weapon niches of:
# Crossbow - Killing single hard enemies
# Shotgun - Killing groups of easy enemies
# Rifle - Killing groups of hard enemies
# Pistol - Snails


static var weapon_unlocks: Dictionary[String, bool] = {
	"PISTOL" = true,
	"RIFLE" = true,
	"SHOTGUN" = false,
	"CROSSBOW" = false,
}

var damage: int
var clip: int
var firespeed: float
var reload: float
var texture: CompressedTexture2D

func _ready() -> void:
	damage = Player.weapon.damage
	clip = Player.weapon.clip_size
	firespeed = Player.weapon.attack_speed
	reload = Player.weapon.reload_speed
	texture = Player.weapon.texture
	
	$GUI/Customisation/Sliders/DamageSlider.value = damage
	$GUI/Customisation/Sliders/ClipSlider.value = clip
	$GUI/Customisation/Sliders/FirespeedSlider.value = firespeed
	$GUI/Customisation/Sliders/ReloadSlider.value = reload
	load_ranges(RANGES["PISTOL"])
	
	for icon: TextureButton in $GUI/Customisation/Icons.get_children(false):
		icon.disabled = not weapon_unlocks.get(icon.name.to_upper())
		if icon.disabled:
			icon.hide()
		else:
			icon.show()

func _process(_delta: float) -> void:
	damage = $GUI/Customisation/Sliders/DamageSlider.value
	clip = $GUI/Customisation/Sliders/ClipSlider.value
	firespeed = $GUI/Customisation/Sliders/FirespeedSlider.value
	reload = $GUI/Customisation/Sliders/ReloadSlider.value
	
	# Refresh the stat display
	var statdisp := $GUI/CurrentWeapon/Stats
	statdisp.text = ""
	statdisp.text += "Damage: " + str(damage) + "\n"
	statdisp.text += "Clip Size: " + str(clip) + "\n"
	statdisp.text += "Firing Speed: " + str(firespeed) + "\n"
	statdisp.text += "Reload Speed: " + str(reload) + "\n"
	$GUI/CurrentWeapon/WeaponDisplay.texture = texture

func exit_menu() -> void:
	exit.emit()
	Player.weapon_inventory.push_back(Weapon.of(
		damage, clip, firespeed, reload, texture
	))
	call_deferred("queue_free")

## This method is probably not safe, it assumes you supply it the
## proper data from the RANGES array
func load_ranges(ranges: Array) -> void:
	$GUI/Customisation/Sliders/DamageSlider.min_value = ranges[0][0]
	$GUI/Customisation/Sliders/DamageSlider.max_value = ranges[0][1]
	$GUI/Customisation/Sliders/ClipSlider.min_value = ranges[1][0]
	$GUI/Customisation/Sliders/ClipSlider.max_value = ranges[1][1]
	$GUI/Customisation/Sliders/FirespeedSlider.min_value = ranges[2][0]
	$GUI/Customisation/Sliders/FirespeedSlider.max_value = ranges[2][1]
	$GUI/Customisation/Sliders/ReloadSlider.min_value = ranges[3][0]
	$GUI/Customisation/Sliders/ReloadSlider.max_value = ranges[3][1]

func _on_exit_button_pressed() -> void:
	exit_menu()

func _on_pistol_pressed() -> void:
	texture = TEXTURES[0]
	load_ranges(RANGES["PISTOL"])

func _on_rifle_pressed() -> void:
	texture = TEXTURES[1]
	load_ranges(RANGES["RIFLE"])

func _on_shotgun_pressed() -> void:
	texture = TEXTURES[2]
	load_ranges(RANGES["SHOTGUN"])

func _on_crossbow_pressed() -> void:
	texture = TEXTURES[3]
	load_ranges(RANGES["CROSSBOW"])
