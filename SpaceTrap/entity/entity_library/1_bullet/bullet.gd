## 弹幕基础脚本
extends Entity
class_name Bullet


func _physics_process(delta: float) -> void:
	var motion = speed * delta * direction.normalized()
	move_and_collide(motion)
