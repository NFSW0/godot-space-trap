## 新手引导空间(关卡0)
extends Node2D


signal end_teach() # 结束教程
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var timer: Timer = $Timer
var skeleton_count = 0
var skeleton_dead_count = 0


func _ready() -> void:
	EventManager.register_event("skeleton_dead", on_skeleton_dead)


func on_skeleton_dead(node):
	skeleton_dead_count += 1
	if skeleton_dead_count >= 5:
		$TileMapLayer.set_cell(Vector2i(15,-1))
		$TileMapLayer.set_cell(Vector2i(15,0))
		$TileMapLayer.set_cell(Vector2i(15,1))
		$TileMapLayer2.visible = true


func _add_skeleton():
	path_follow_2d.progress_ratio = randf_range(0.0,1.0)
	var spawn_posiiton = path_follow_2d.global_position
	EntityManager.generate_entity({"entity_id": 5, "position": spawn_posiiton})


func _on_timer_timeout() -> void:
	_add_skeleton()
	skeleton_count += 1
	if skeleton_count >= 5:
		timer.stop()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$TileMapLayer.enabled = false
	$TileMapLayer.visible = false
	$TileMapLayer3.visible = true
	$TileMapLayer3.enabled = true
	$TileMapLayer3/Area2D/CollisionShape2D.disabled = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		end_teach.emit()
