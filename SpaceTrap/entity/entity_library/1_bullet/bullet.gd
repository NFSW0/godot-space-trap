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
		var collision_normal:Vector2 = shape_cast_2d.get_collision_normal(0)
		var hitData = HitData.new(self.get_path(),body.get_path(),collision_normal)
		HitManager.append_hit_event(hitData.serialize())
