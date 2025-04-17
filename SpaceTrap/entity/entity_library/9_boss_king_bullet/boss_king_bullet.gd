extends Entity2D


func animation_attack():
	var bodies = $Area2D.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			body.mass -= 10


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
