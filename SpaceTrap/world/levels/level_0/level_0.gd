## 新手引导空间(关卡0)
extends Node2D


@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var timer: Timer = $Timer
var skeleton_count = 0


func _add_skeleton():
	path_follow_2d.progress_ratio = randf_range(0.0,1.0)
	var spawn_posiiton = path_follow_2d.global_position
	EntityManager.generate_entity({"entity_id": 5, "position": spawn_posiiton})


func _on_timer_timeout() -> void:
	_add_skeleton()
	skeleton_count += 1
	if skeleton_count >= 5:
		timer.stop()
