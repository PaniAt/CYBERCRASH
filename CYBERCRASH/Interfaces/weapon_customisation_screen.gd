extends CanvasLayer

signal exit()

const TEXTURES: Array[CompressedTexture2D] = [
	preload("res://GFX/GunTextures/pickup_pistol.png"),
	preload("res://GFX/GunTextures/pickup_rifle.png"),
	preload("res://GFX/GunTextures/pickup_shotgun.png"),
	preload("res://GFX/GunTextures/pickup_crossbow.png"),
]

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

func _process(_delta: float) -> void:
	damage = $GUI/Customisation/Sliders/DamageSlider.value
	clip = $GUI/Customisation/Sliders/ClipSlider.value
	firespeed = $GUI/Customisation/Sliders/FirespeedSlider.value
	reload = $GUI/Customisation/Sliders/ReloadSlider.value
	
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

func _on_exit_button_pressed() -> void:
	exit_menu()


func _on_pistol_pressed() -> void:
	texture = TEXTURES[0]

func _on_rifle_pressed() -> void:
	texture = TEXTURES[1]

func _on_shotgun_pressed() -> void:
	texture = TEXTURES[2]

func _on_crossbow_pressed() -> void:
	texture = TEXTURES[3]
