## 假人动画(二维变量):静默(Idle)、移动(Move)、受伤(Hurt)、死亡(Dead)
extends InfluenceableEntity2D
#class_name Dummy


@export var animation_tree: AnimationTree ## 动画节点
@export var collision_shape_2d: CollisionShape2D ## 碰撞检测节点


func _ready() -> void:
	mass_changed.connect(_on_mass_changed) # 连接信号


#region 质量(生命)
var old_health : float = 0.0
## 处理质量变化
func _on_mass_changed(new_health : float) -> void:
	if new_health < 0.01:
		_death()
		return
	if old_health > new_health:
		travel_animation("Hurt")
		var entity_manager = get_node_or_null("/root/EntityManager")
		if entity_manager:
			var attack_velocity = (attack_position - position).normalized() * damage
			(entity_manager as EntityManager).generate_entity_immediately({"entity_id": 7, "position":position, "velocity":attack_velocity, "process_collisions": process_collisions})
	#set("scale", Vector2(new_health / DEFAULT_MASS, new_health / DEFAULT_MASS))
	old_health = new_health
## 死亡
func _death():
	controllable = false
	collision_shape_2d.disabled = true
	remove_from_group("Player")
	travel_animation("Dead")
	animation_tree.get("parameters/playback").start("Dead", true)
#endregion 质量(生命)


#region 动画
## 过度到另一个动画 传入动画名称
func travel_animation(animation_name: String, reset_on_teleport: bool = true):
	if animation_tree:
		animation_tree.set("parameters/%s/blend_position" % animation_name, velocity.normalized())
		animation_tree.get("parameters/playback").travel(animation_name, reset_on_teleport)
#endregion 动画


#region 行动中心
## 执行行动指令
## 遍历传入的指令字典，并根据指令类型执行相应的行动
func _execute_command(command: Dictionary) -> void:
	if command.is_empty():
		travel_animation("Idle")
		return
	for command_type:ControllerBase.COMMAND_TYPE in command:
		match command_type:
			ControllerBase.COMMAND_TYPE.MOVE_TO:
				_move_to(command[command_type])
			ControllerBase.COMMAND_TYPE.MOVE_TOWARD:
				_move_toward(command[command_type])
			ControllerBase.COMMAND_TYPE.ATTACK:
				_attack(command[command_type])

## 定点移动
## 通过导航代理计算路径并移动至指定位置
func _move_to(data: Vector2 = Vector2()) -> void:
	if navigation_agent_2d:
		var map_rid = navigation_agent_2d.get_navigation_map()
		navigation_agent_2d.target_position = data
		# 已更新寻路且未抵达最终位置
		if NavigationServer2D.map_get_iteration_id(map_rid) and not navigation_agent_2d.is_navigation_finished():
			var next_path_position:Vector2 = navigation_agent_2d.get_next_path_position()
			navigation_agent_2d.set_velocity((next_path_position - position).normalized() * speed)
			# 避障计算独立进行，因此在信号方法直接设置速度会导致不断移动
			if velocity_move_to:
				_move(velocity_move_to)

## 定向移动
## 直接朝指定方向移动，不依赖导航系统
func _move_toward(_direction: Vector2 = Vector2()) -> void:
	_move(_direction.normalized() * speed)

## 攻击
## 若可攻击，则进入攻击状态，并设置冷却时间
func _attack(data: Vector2 = Vector2())-> void:
	if not can_attacking:
		return
	can_attacking = false
	get_tree().create_timer(attack_cooldown).connect("timeout", func():can_attacking = true)
	attack_position = data if data else get_global_mouse_position()
	travel_animation("Attack") # 动画帧中设置可控状态 - 攻击动画中处于失控状态
	animation_tree.get("parameters/playback").start("Attack", true)
#endregion 行动中心


#region 行动附属-攻击
var attack_position = position ## 进攻坐标
var attack_cooldown = 1.0  ## 攻击冷却时间（秒）
var can_attacking = true ## 是否可以进行攻击
var penetration:int = 0 ## 穿透数，可命中多个目标时，最多命中 [穿透数] 个目标，<=0 表示无限
var damage = 100 ## 伤害值

## 动画帧回调方法
## 生成实体（如投射物）并赋予其初始速度
func animation_attack():
	var entity_manager = get_node_or_null("/root/EntityManager")
	if entity_manager:
		var attack_velocity = (attack_position - position).normalized() * damage
		(entity_manager as EntityManager).generate_entity_immediately({"entity_id": 1, "position":position, "velocity":attack_velocity, "process_collisions": process_collisions})

## 命中回调方法（接收所有碰撞信息，按距离排序）
func process_collisions(bullet: Node, collisions: Array):
	var max_hits = penetration if penetration > 0 else collisions.size()
	var hits = 0
	for collision in collisions:
		if hits >= max_hits:
			break
		var collider = collision["collider"] # 额外参数包括: point, distance, normal
		# 排除自己
		if collider == self or not collider:
			continue
		# 处理碰撞（包括伤害）
		var hitData = HitData.new(bullet.get_path(), collider.get_path(), collision["normal"])
		HitManager.append_hit_event(hitData.serialize())
		# 添加击退效果
		var buff_manager = get_node_or_null("/root/BuffManager")
		if buff_manager and collider is ControllableEntity2D:
			buff_manager.append_buff(3, collider.get_path(), {"knockback_velocity":(attack_position - position).normalized() * damage})
		hits += 1
#endregion 行动附属-攻击


#region 行动附属-移动
@export var speed:float = 100 ## 移动速度
@export var navigation_agent_2d: NavigationAgent2D ## 导航代理节点
var velocity_move_to: Vector2 = Vector2() ## 经过避障计算后的移动速度

## 统一移动逻辑，调用 move_and_slide 进行物理移动
func _move(final_velocity: Vector2 = Vector2()):
	velocity = final_velocity
	travel_animation("Move")
	move_and_slide()

## 导航避障更新回调
## 计算安全速度，避免碰撞
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity_move_to = safe_velocity
#endregion 行动附属-移动
