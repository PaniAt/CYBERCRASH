class_name BloodExplosion
extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Particles.emitting = true

func _on_particles_finished() -> void:
	call_deferred("queue_free")
