## 基础弹幕
extends Entity2D
#class_name Bullet


@export var shape_cast_2d: ShapeCast2D
@export var animation_player: AnimationPlayer
@export var readied = false ## 弹幕初始化动画完成后设置为true
var lock = false ## 更新限制锁，避免多次碰撞
var process_collisions:Callable = Callable() # 接收撞击数组 每个元素包含 撞击对象 撞击点 撞击距离


func _ready() -> void:
	mass_changed.connect(_on_mass_changed) # 连接信号
	velocity = velocity # 刷新速度


func _physics_process(delta: float) -> void:
	if not readied:
		return
	var move_delta = velocity * delta
	_process_collide(move_delta)
	move_and_collide(move_delta)

## 碰撞处理
func _process_collide(move_delta):
	shape_cast_2d.set("target_position", move_delta)
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

## 质量变化处理
func _on_mass_changed(new_mass : float) -> void:
	#set("scale", Vector2(new_mass / DEFAULT_MASS, new_mass / DEFAULT_MASS))
	if new_mass < 0.1:
		call_deferred("queue_free")
