## 弹幕基础脚本
extends Area2D
class_name Bullet


@export var entity_id:int = 0
@export var direction:Vector2 = Vector2()
@export var speed:float = 0
@export var mass:float = 1
@onready var shape_cast_2d: ShapeCast2D = $ShapeCast2D


func _physics_process(delta: float) -> void:
	var motion = speed * delta * direction.normalized()
	position += motion


func _on_body_entered(body: Node2D) -> void:
	if shape_cast_2d.is_colliding():
		for collision_result in shape_cast_2d.collision_result:
			pass
		var collision_normal:Vector2 = shape_cast_2d.get_collision_normal(0)
		HitManager.append_hit_event({"node_path_1":self.get_path(), "node_path_2":body.get_path(), "normal":collision_normal})
