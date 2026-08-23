class_name Terminal
extends MeshInstance3D

@export_multiline var text: String
@export var style: LabelSettings

func _ready() -> void:
	$Display/Text.text = text
	$Display/Text.style = style

func _on_detect_body_entered(_body: Node3D) -> void:
	CameraController.paused_by_force = true
	$Display/Text.reload()
	$Display.show()
	$Display/Text.start()
