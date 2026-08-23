class_name Weapon
extends Object

# Weapon parameters
var damage: int
var clip_size: int
var bullets: int
var can_shoot: bool
var attack_speed: float
var reload_speed: float
var texture: CompressedTexture2D

## Constructs a new weapon
static func of(
	weapon_damage: int,
	weapon_clip: int,
	weapon_attack_speed: float,
	weapon_reload_speed: float,
	weapon_texture := preload("res://GFX/GunTextures/pickup_pistol.png")
	) -> Weapon:
	var weapon := Weapon.new()
	weapon.damage = weapon_damage
	weapon.clip_size = weapon_clip
	weapon.bullets = weapon.clip_size
	weapon.can_shoot = true
	weapon.attack_speed = weapon_attack_speed
	weapon.reload_speed = weapon_reload_speed
	weapon.texture = weapon_texture
	return weapon

## This is EXTREMELY UNSAFE and WILL THROW ERRORS at even
## the slightest hint of something being wrong
static func ofstr(weapon_string: String) -> Weapon:
	var weapon := Weapon.new()
	var values := weapon_string.split("|")
	weapon.damage = int(values[0])
	weapon.clip_size = int(values[1])
	weapon.bullets = weapon.clip_size
	weapon.can_shoot = true
	weapon.attack_speed = float(values[4])
	weapon.reload_speed = float(values[5])
	weapon.texture = load(values[6]) as CompressedTexture2D
	return weapon

## Returns whether the weapon can be fired
func is_fireable() -> bool:
	return bullets > 0 and can_shoot

## Retuns whether the weapon has any bullets loaded
func is_loaded() -> bool:
	return bullets > 0

## Reloads the weapon
func reload() -> void:
	bullets = clip_size

## Gets amount of ammo this wepaon has as some nicely formatted 
## text (this is for the GUI)
func ammo_text() -> String:
	return str(bullets) + " / " + str(clip_size)

## Encodes this weapon into a string
func str_encode() -> String:
	var out := ""
	out += str(damage) + "|"
	out += str(clip_size) + "|"
	out += str(bullets) + "|"
	out += str(can_shoot) + "|"
	out += str(attack_speed) + "|"
	out += str(reload_speed) + "|"
	out += str(texture.resource_path)
	return out
