# GOAP人工智能核心
extends Node
class_name GOAPBrain

var current_goal: GOAPGoal = null
var available_actions: Array = []
var goals: Array = []
var current_plan: Array = []
var world_state: Dictionary = {}

# 初始化配置
func setup(initial_actions: Array, initial_goals: Array):
	available_actions = initial_actions.duplicate()
	goals = initial_goals.duplicate()
	update_world_state()

# 更新世界状态（需要根据实际情况实现）
func update_world_state():
	# 示例状态采集：
	#world_state = {
		#"has_weapon": check_weapon(),
		#"enemy_visible": check_enemy_visibility(),
		#"low_health": actor.health < 30,
		#"near_cover": check_nearby_cover()
	#}
	world_state = {
		"has_weapon": false,
		"enemy_visible": true,
		"low_health": true,
		"near_cover": false
	}

# 生成行动计划
func plan() -> Array:
	var best_goal = select_best_goal()
	if not best_goal:
		return []
	
	# 使用A*算法寻找最优行动路径
	#var planner = GOAPPlanner.new()
	var planner
	return planner.find_plan(
		available_actions,
		world_state,
		best_goal.desired_effects
	)

# 选择当前最佳目标
func select_best_goal() -> GOAPGoal:
	var selected = null
	var max_priority = -1
	
	for goal in goals:
		if goal.is_valid(world_state):
			var p = goal.calculate_priority(world_state)
			if p > max_priority:
				max_priority = p
				selected = goal
				
	return selected

# 决策下一行动
func decide_next_action() -> Dictionary:
	update_world_state()
	
	# 如果没有计划或当前目标失效，重新规划
	if current_plan.is_empty() or not current_goal.is_valid(world_state):
		current_plan = plan()
		if current_plan.is_empty():
			return {}
	
	# 执行计划中的第一个行动
	var current_action = current_plan.pop_front()
	#var result = current_action.perform(actor)
	var result = current_action.perform()
	
	# 处理行动结果
	if result.get("status") == "completed":
		# 应用行动效果到世界状态
		for key in current_action.effects:
			world_state[key] = current_action.effects[key]
	elif result.get("status") == "failed":
		current_plan = []  # 需要重新规划
		
	return convert_action_to_command(current_action)

# 将GOAP行动转换为控制器命令
func convert_action_to_command(action: GOAPAction) -> Dictionary:
	var command = {}
	
	#if action is MoveToAction:
		#command[ControllerBase.COMMAND_TYPE.MOVE_TO] = action.target_position
	#
	#elif action is AttackAction:
		#command[ControllerBase.COMMAND_TYPE.ATTACK] = true
	
	# ...其他行动类型转换
	
	return command
