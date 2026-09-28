extends CanvasLayer

var ability := Player.Ability.NONE
var selected := false

func _ready() -> void:
	CameraController.paused_by_force = true

func _process(_delta: float) -> void:
	$Main/ConfirmButton.visible = selected

## This is corrupt, ignore the name
func _on_xray_button_pressed() -> void:
	selected = true
	ability = Player.Ability.CORRUPT

## This is predict, ignore the name
func _on_glitch_button_pressed() -> void:
	selected = true
	ability = Player.Ability.PREDICT

## This is invisibility, ignore the name
func _on_agility_button_pressed() -> void:
	selected = true
	ability = Player.Ability.INVISIBILITY

## This is x-ray, ignore the name
func _on_none_button_pressed() -> void:
	selected = true
	ability = Player.Ability.XRAY


func _on_confirm_button_pressed() -> void:
	CameraController.paused_by_force = false
	Player.ability = ability
	ScreenTransition.change_scene("res://Levels/level_5.tscn")
