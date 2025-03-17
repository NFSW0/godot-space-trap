## 基础弹幕
extends Entity2D
#class_name Bullet


@export var shape_cast_2d: ShapeCast2D


func _ready() -> void:
	velocity = speed * direction


func _physics_process(delta: float) -> void:
	if shape_cast_2d.is_colliding():
		var collision_normal:Vector2 = shape_cast_2d.get_collision_normal(0)
		var collider = shape_cast_2d.get_collider(0)
		var hitData = HitData.new(self.get_path(),collider.get_path(),collision_normal)
		HitManager.append_hit_event(hitData.serialize())
	move_and_collide(velocity * delta)
