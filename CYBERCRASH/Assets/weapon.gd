class_name Weapon
extends Object

var damage: int
var clip_size: int
var bullets: int
var can_shoot: bool
var attack_speed: float
var reload_speed: float
var texture: CompressedTexture2D

static func of(
	weapon_damage: int,
	weapon_clip: int,
	weapon_attack_speed: float,
	weapon_reload_speed: float,
	weapon_texture := preload("res://GFX/GunTextures/pickup_pistol.png")) -> Weapon:
	var weapon := Weapon.new()
	weapon.damage = weapon_damage
	weapon.clip_size = weapon_clip
	weapon.bullets = weapon.clip_size
	weapon.can_shoot = true
	weapon.attack_speed = weapon_attack_speed
	weapon.reload_speed = weapon_reload_speed
	weapon.texture = weapon_texture
	return weapon

func is_fireable() -> bool:
	return bullets > 0 and can_shoot

func is_loaded() -> bool:
	return bullets > 0

func reload() -> void:
	bullets = clip_size

func ammo_text() -> String:
	return str(bullets) + " / " + str(clip_size)
