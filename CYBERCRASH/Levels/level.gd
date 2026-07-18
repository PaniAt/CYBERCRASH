class_name Level
extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CameraController.world_environment = $WorldEnvironment
	CameraController.has_world_environment = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$WorldEnvironment.environment.tonemap_exposure = Settings.gamma

func _on_detection_body_entered(body: Node3D) -> void:
	assert(body is Player, "Expected player: " + str(body))
	body.call_deferred("queue_free")

#I wish you'd get me, I know you never could
#You think I'm lazy, always misunderstood
#I used to have dreams, but they all went away
#Replaced with visions of killing myself every day

#Oh, I just hate this
#Everything sucks, life's overrated
#Oh, I can't take it
#It's my life and I'm gonna waste it!

#I have no more hope left in store
#I have no more hope left in store
#I have no more hope left in store
#I have no more hope left in store
#I have no more, I have no more

#Oh, I just hate this
#Everything sucks, life's overrated
#Oh, I can't take it
#It's my life and I'm gonna take it!
