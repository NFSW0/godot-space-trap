## 首领-君王
#class_name King
extends ControllableEntity2D


var attack_range : float = 100 ## 攻击距离


func _ready() -> void:
	mass_changed.connect(_on_mass_changed) # 连接信号
	_set_brain()


#region 质量(生命)
var old_health : float = 0.0
## 处理质量变化
func _on_mass_changed(new_health : float) -> void:
	if new_health < 0.01:
		_death()
		return
	if old_health > new_health:
		travel_animation("Hurt")
	#set("scale", Vector2(new_health / DEFAULT_MASS, new_health / DEFAULT_MASS))
	old_health = new_health
## 死亡
func _death():
	controllable = false
	travel_animation("Dead")
	animation_tree.get("parameters/playback").start("Dead", true)
#endregion 质量(生命)


#region 动画
@export var animation_tree: AnimationTree ## 动画节点
## 过渡到另一个动画 传入动画名称
func travel_animation(animation_name: String, reset_on_teleport: bool = true):
	if animation_tree:
		animation_tree.set("parameters/%s/blend_position" % animation_name, velocity.normalized().x)
		animation_tree.get("parameters/playback").travel(animation_name, reset_on_teleport)
#endregion 动画



#region 智能-决策
func _set_brain():
	var ai_brain = GOAP_AIBrain.new()
	# 设置世界状态更新方法
	ai_brain.world_update = _update_local_state
	# 添加目标(不同对象可以有不同目标)
	ai_brain.current_goals.append(
		GOAP_AIBrain.GOAPGoal.new(
			"AttackTarget",
			90.0,
			{"target_destroyed": true}
		)
	)
	# 添加行动
	ai_brain.available_actions.append(
		GOAP_AIBrain.GOAPAction.new(
			"MoveToTarget",
			{"target_position": func(v): return position.distance_to(v) > attack_range if v else false},
			{"target_in_range": true},
			1.0,
			func (state): return {ControllerBase.COMMAND_TYPE.MOVE_TO: state["target"].get("position")}
		)
	)
	ai_brain.available_actions.append(
		GOAP_AIBrain.GOAPAction.new(
			"AttackTarget",
			{"target_in_range": true},
			{"target_destroyed": true},
			2.0,
			func(state): return {ControllerBase.COMMAND_TYPE.ATTACK: state["target"].get("position")}
		)
	)
	controller.set("ai_brain", ai_brain)


# 更新本地状态条件
func _update_local_state() -> Dictionary:
	var local_state = {}
	
	var target = _perceptual()
	if not target: return local_state
	local_state["target"] = target
	
	var target_position = target.get("position")
	if not target_position: return local_state
	local_state["target_position"] = target_position
	
	var target_in_range = position.distance_to(target_position) < attack_range
	local_state["target_in_range"] = target_in_range
	
	return local_state
#endregion 智能-决策


#region 智能-感知
@export var perceptron: Area2D ## 感知节点
# 感知(用于确定行动目标)
func _perceptual() -> Node:
	var nodes_in_area = perceptron.get_overlapping_areas() + perceptron.get_overlapping_bodies()
	# 排除无关对象
	nodes_in_area = nodes_in_area.filter(func(element): return element.is_in_group("Player"))
	if nodes_in_area.is_empty():
		return null
	nodes_in_area.sort_custom(_compare_priority)
	return nodes_in_area[0]
# 排序
func _compare_priority(a: Node, b: Node) -> int:
	# 近距离优先
	var dist_a = position.distance_to(a.position)
	var dist_b = position.distance_to(b.position)
	return dist_a < dist_b
#endregion 智能-感知



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
	controllable = false
	travel_animation("Attack1") # 动画帧中设置可控状态 - 攻击动画中处于失控状态
	animation_tree.get("parameters/playback").start("Attack1", true)
	await animation_tree.animation_finished
	controllable = true
#endregion 行动中心


#region 行动附属-攻击
var attack_position = position ## 进攻坐标
var attack_cooldown = 1.0  ## 攻击冷却时间（秒）
var can_attacking = true ## 是否可以进行攻击
var penetration:int = 0 ## 穿透数，可命中多个目标时，最多命中 [穿透数] 个目标，<=0 表示无限
var damage = 10 ## 伤害值

## 动画帧回调方法
## 生成实体（如投射物）并赋予其初始速度
func animation_attack():
	var entity_manager = get_node_or_null("/root/EntityManager")
	if entity_manager:
		var attack_velocity = (attack_position - position).normalized() * damage
		(entity_manager as EntityManager).generate_entity_immediately({"entity_id": 6, "position":position, "velocity":attack_velocity, "process_collisions": process_collisions})

## 命中回调方法（接收所有碰撞信息，按距离排序）
func process_collisions(bullet: Node, collisions: Array):
	var max_hits = penetration if penetration > 0 else collisions.size()
	var hits = 0
	for collision in collisions:
		if hits >= max_hits:
			break
		var collider = collision["collider"] # 额外参数包括: point, distance, normal
		# 排除自己
		if collider == self:
			continue
		# 处理碰撞（包括伤害）
		var hitData = HitData.new(bullet.get_path(), collider.get_path(), collision["normal"])
		HitManager.append_hit_event(hitData.serialize())
		# 添加击退效果
		var buff_manager = get_node_or_null("/root/BuffManager")
		if buff_manager:
			buff_manager.append_buff(3, collider.get_path(), {"knockback_velocity":(attack_position - position).normalized() * damage})
		hits += 1
#endregion 行动附属-攻击


#region 行动附属-移动
@export var speed:float = 50 ## 移动速度
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
