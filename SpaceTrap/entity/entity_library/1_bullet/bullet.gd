## 弹幕基础脚本
extends Entity2D
class_name Bullet


@export var shape_cast_2d: ShapeCast2D


func _physics_process(delta: float) -> void:
	var motion = speed * delta * direction.normalized() / scale # 除以scale以维持视觉速度
	position += motion


# 使用shape_cast_2d检测碰撞和法线
func _on_body_entered(body: Node2D) -> void:
	if shape_cast_2d.is_colliding():
		var collision_normal:Vector2 = shape_cast_2d.get_collision_normal(0)
		var hitData = HitData.new(self.get_path(),body.get_path(),collision_normal)
		HitManager.append_hit_event(hitData.serialize())
