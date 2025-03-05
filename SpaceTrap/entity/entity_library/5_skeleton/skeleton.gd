## 骷髅动画(二维变量):静默(Idle)、移动(Move)、受伤(Hurt)、死亡(Dead)
# TODO 无目标有路径->前往路径终点
# TODO 无目标无路径->自由行动
# TODO 可攻击有路径->优先攻击
extends InfluenceableEntity2D
#class_name Skeleton


func _ready() -> void:
	_connect_health_signal()
	_set_brain()


#region 生命
signal health_changed(old_value: float, new_value: float, max_health: float)
@export var health_max: float = 20.0:
	set(value):
		if value != health_max:
			value = clamp(value, 0, INF)
			health_changed.emit(health_old, health_current, value)
			health_max = value
@export var health_current: float = 20.0:
	set(value):
		if value != health_current:
			value = clamp(value, 0, health_max)
			health_changed.emit(health_old, value, health_max)
			health_old = health_current
			health_current = value
var health_old: float = 20.0
func _connect_health_signal(node:Node = self):
	node.connect("health_changed", _on_health_changed)
func _on_health_changed(_old_value: float, new_value: float, max_health: float):
	if new_value <= 0 or max_health <= 0:
		_death()
		return
#endregion 生命


#region 动画
@export var animation_tree: AnimationTree ## 动画节点
## 过渡到另一个动画 传入动画名称
func travel_animation(animation_name: String):
	if animation_tree:
		animation_tree.get("parameters/playback").travel(animation_name)
#endregion 动画


#region 智能-决策
func _update_local_state() -> Dictionary:
	var local_state = {}
	
	var target = _perceptual()
	if not target: return local_state
	local_state["target"] = target
	
	var target_position = target.get("position")
	if not target_position: return local_state
	local_state["target_position"] = target_position
	
	var target_in_range = position.distance_to(target_position) < navigation_agent_2d.target_desired_distance
	local_state["target_in_range"] = target_in_range
	
	return local_state

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
			{"target_position": func(v): return position.distance_to(v) > navigation_agent_2d.target_desired_distance if v else false},
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
			func(_state): return {ControllerBase.COMMAND_TYPE.ATTACK: true}
		)
	)
	controller.set("ai_brain", ai_brain)
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


#region 行动
## 执行行动指令
func _execute_command(command: Dictionary) -> void:
	for command_type:ControllerBase.COMMAND_TYPE in command:
		match command_type:
			ControllerBase.COMMAND_TYPE.MOVE_TO:
				_move_to(command[command_type])
			ControllerBase.COMMAND_TYPE.ATTACK:
				_attack(command[command_type])


## 定点移动
@export var navigation_agent_2d: NavigationAgent2D ## 导航节点
func _move_to(data: Vector2 = Vector2()) -> void:
	if navigation_agent_2d:
		var map_rid = navigation_agent_2d.get_navigation_map()
		navigation_agent_2d.target_position = data
		# 已更新寻路且未抵达最终位置
		if NavigationServer2D.map_get_iteration_id(map_rid) and not navigation_agent_2d.is_navigation_finished():
			var next_path_position:Vector2 = navigation_agent_2d.get_next_path_position()
			velocity = (next_path_position - position) * speed
			animation_tree.set("parameters/Move/blend_position", velocity)
			travel_animation("Move")
			#_move_toward(next_path_position - position)
			navigation_agent_2d.set_velocity(velocity)
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()


## 定向移动
func _move_toward(_direction: Vector2 = Vector2()) -> void:
	direction = _direction
	velocity = direction.normalized() * speed
	animation_tree.set("parameters/Move/blend_position", velocity)
	travel_animation("Move")
	move_and_slide()


## 攻击
func _attack(_data = null)-> void:
	print("(攻击动画)")
	do_influence(hurt)
func hurt(_entity: InfluenceableEntity2D):
	health_current -= 7
	if not health_current > 0:
		return
	
	controllable = false
	var timer = get_tree().create_timer(0.5)
	timer.connect("timeout", func(): controllable = true)
	
	animation_tree.set("parameters/Hurt/blend_position", velocity)
	travel_animation("Hurt")
	
	var buff_manager = get_node_or_null("/root/BuffManager")
	if buff_manager:
		buff_manager.append_buff(3, get_path(), {"knockback_velocity":direction.normalized() * speed * -1})


## 死亡
func _death():
	controllable = false
	animation_tree.set("parameters/Dead/blend_position", direction)
	travel_animation("Dead")
#endregion 行动
