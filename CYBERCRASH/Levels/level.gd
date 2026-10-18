class_name Level
extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CameraController.world_environment = $WorldEnvironment
	CameraController.has_world_environment = true
	$Music.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$WorldEnvironment.environment.tonemap_exposure = Settings.gamma

## When the player wins the level
func _on_detection_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected player: " + str(body))
	body.call_deferred("queue_free")
# (26/08/2026) why the hell did I write this?
# (16/10/2026) removed what I wrote.
