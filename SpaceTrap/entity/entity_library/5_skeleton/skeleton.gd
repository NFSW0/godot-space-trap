## 骷髅动画(二维变量):静默(Idle)、移动(Move)、受伤(Hurt)、死亡(Dead)
extends InfluenceableEntity2D
#class_name Skeleton


@export var animation_tree: AnimationTree ## 动画节点
@export var navigation_agent_2d: NavigationAgent2D ## 导航节点


func _ready() -> void:
	# 初始化AI大脑示例
	var ai_brain = GOAP_AIBrain.new()
	# 设置世界状态更新方法
	ai_brain.world_update = func():
		return {
			"has_target": true,
			"target_position": Vector2(100, 200),
			"health": 80.0,
			"ammo": 5
		}
	# 添加目标
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
			{"target_position": func(v:Vector2): return v.distance_to(position) > navigation_agent_2d.target_desired_distance},
			{"in_range": true},
			1.0,
			func(state): return {ControllerBase.COMMAND_TYPE.MOVE_TO: state["target_position"]}
		)
	)
	ai_brain.available_actions.append(
		GOAP_AIBrain.GOAPAction.new(
			"ShootTarget",
			{"in_range": true, "ammo": func(v): return v > 0},
			{"target_destroyed": true},
			2.0,
			func(state): return {ControllerBase.COMMAND_TYPE.ATTACK: true}
		)
	)
	controller.set("ai_brain", ai_brain)


## 过渡到另一个动画 传入动画名称
func travel_animation(animation_name: String):
	if animation_tree:
		animation_tree.get("parameters/playback").travel(animation_name)


## 感知到实体时触发(用于发现行动目标并决策行动计划)
func _on_perceived_target(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# 通知AI发现目标
		pass


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
func _move_to(data: Vector2 = Vector2()) -> void:
	if navigation_agent_2d:
		var map_rid = navigation_agent_2d.get_navigation_map()
		var agent_rid = navigation_agent_2d.get_rid()
		navigation_agent_2d.target_position = data
		# 已更新且未抵达最终位置
		if NavigationServer2D.map_get_iteration_id(map_rid) and not navigation_agent_2d.is_navigation_finished():
			var next_path_position:Vector2 = navigation_agent_2d.get_next_path_position()
			velocity = (next_path_position - position).normalized() * speed
			move_and_slide()


## 攻击
func _attack(data = null)-> void:
	print("骷髅发动攻击")
#endregion 行动
