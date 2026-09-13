extends CanvasLayer
# You win! Perfect!

func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"death_text" and Player.nohit: # It's the death screen retextured
		$NoHitText.show()
