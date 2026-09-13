class_name Terminal
extends MeshInstance3D

@export_multiline var text: String
@export var style: LabelSettings

var open := false ## Is the terminal open

func _ready() -> void:
	$Display/Text.text = text
	$Display/Text.style = style

## When something enters the terminal opening area
func _on_detect_body_entered(_body: Node3D) -> void:
	CameraController.paused_by_force = true
	$Display/Text.reload()
	$Display/Text.start()
	$Display.show()
	open = true

## When the terminal is exited
func _on_exit_button_pressed() -> void:
	$Display.hide()
	CameraController.paused_by_force = false
	CameraController.unpause()
	open = false
