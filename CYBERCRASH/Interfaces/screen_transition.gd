extends CanvasLayer

## Changes the current scene to a specified file over a given amount of time
func change_scene(path: String, speed := 1.0) -> void:
	$Animation.speed_scale = speed
	$Animation.play("change_scene")
	await get_tree().create_timer(1.0 / speed).timeout
	get_tree().change_scene_to_file(path)
	await $Animation.animation_finished
	$Animation.speed_scale = 1.0
