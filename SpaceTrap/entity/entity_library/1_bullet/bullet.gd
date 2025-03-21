## 基础弹幕
extends Entity2D
#class_name Bullet


@export var shape_cast_2d: ShapeCast2D


var lock = false


func _ready() -> void:
	mass_changed.connect(_on_mass_changed) # 连接信号
	velocity = velocity # 刷新速度


func _physics_process(delta: float) -> void:
	move_and_collide(velocity * delta)
	if shape_cast_2d.is_colliding():
		if lock:
			return
		lock = true
		var collision_normal:Vector2 = shape_cast_2d.get_collision_normal(0)
		var collider = shape_cast_2d.get_collider(0)
		if collider == null:
			return
		var hitData = HitData.new(self.get_path(), collider.get_path(), collision_normal)
		HitManager.append_hit_event(hitData.serialize())
	else:
		if lock:
			lock = false


func _on_mass_changed(new_mass : float) -> void:
	set("scale", Vector2(new_mass / DEFAULT_MASS, new_mass / DEFAULT_MASS))
	if new_mass < 0.1:
		call_deferred("queue_free")
