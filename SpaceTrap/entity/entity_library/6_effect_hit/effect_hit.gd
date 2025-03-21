extends Entity2D
#class_name EffectHit


@export var particles:GPUParticles2D
@export var shape_cast_2d: ShapeCast2D


var process_collisions:Callable = Callable() # 接收撞击数组 每个元素包含 撞击对象 撞击点 撞击距离
var lock = false


func _ready() -> void:
	rotation = atan2(velocity.y, velocity.x)
	particles.restart() # 播放粒子特效


func _physics_process(_delta: float) -> void:
	if not shape_cast_2d.is_colliding():
		lock = false
		return
	if lock:
		return
	lock = true
	
	var collisions = [] # 存储碰撞信息
	
	# 收集所有碰撞信息
	for index in range(shape_cast_2d.get_collision_count()):
		var collider = shape_cast_2d.get_collider(index)
		var collision_point = shape_cast_2d.get_collision_point(index)
		var collision_normal:Vector2 = shape_cast_2d.get_collision_normal(index)
		var distance = global_position.distance_to(collision_point)
		collisions.append({"collider": collider, "point": collision_point, "distance": distance, "normal": collision_normal})
	
	# 按距离排序
	collisions.sort_custom(func(a, b): return a["distance"] < b["distance"])
	
	# 交给 process_collisions 处理
	if process_collisions:
		process_collisions.call(self, collisions)


func _on_finished() -> void:
	call_deferred("queue_free")
