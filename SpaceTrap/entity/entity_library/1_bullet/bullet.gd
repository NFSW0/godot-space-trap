## 弹幕基础脚本
extends Entity
class_name Bullet


func _physics_process(delta: float) -> void:
	var motion = speed * delta * direction.normalized()
	move_and_collide(motion)


func _on_body_entered(body: Node2D) -> void:
	var collision_normal = body.get_collision_normal()
	pass # Replace with function body.
