## 弹幕基础脚本
extends Area2D
class_name Bullet


@export var entity_id:int = 0
@export var direction:Vector2 = Vector2()
@export var speed:float = 0
@export var mass:float = 1


func _physics_process(delta: float) -> void:
	var motion = speed * delta * direction.normalized()
	position += motion
	pass


func _on_body_entered(body: Node2D) -> void:
	var collision_normal = body.get_collision_normal()
	pass # Replace with function body.
