class_name WeaponConsole
extends StaticBody3D

signal opened()
signal closed()

var usable := true

## Opens the weapon console screen
func _on_detection_body_entered(body: Node3D) -> void:
	# This is not where the actual customisation happens, it only
	# triggers it. See:
	# res://Interfaces/weapon_customisation_scene.gd
	assert(body is Player, "Expected Player: " + str(body))
	if not usable:
		return
	CameraController.paused_by_force = true
	const SCENE = preload("res://Interfaces/weapon_customisation_screen.tscn")
	var screen = SCENE.instantiate() as CanvasLayer
	add_sibling(screen)
	opened.emit()
	screen.connect("exit", _on_screen_exit)

## When the screen is exited
func _on_screen_exit() -> void:
	CameraController.paused_by_force = false
	CameraController.paused = false
	closed.emit()
