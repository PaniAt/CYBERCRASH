extends Node3D

func _ready() -> void:
	print("Why are you loading me?")

func _process(_delta: float) -> void:
	#$Geometry/Floor1/Texture.mesh.material.uv1_offset.x += delta
	pass

func _on_detect_body_entered(_body: Node3D) -> void:
	ScreenTransition.change_scene("res://Interfaces/win_scene.tscn")
