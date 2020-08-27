extends Node2D

signal inflict_hit
signal finished

func _on_AnimationPlayer_animation_finished(_anim_name) -> void:
	emit_signal("finished")
	queue_free()

func inflict_hit() -> void:
	emit_signal("inflict_hit")
