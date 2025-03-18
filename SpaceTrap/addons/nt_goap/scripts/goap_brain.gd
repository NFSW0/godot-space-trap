class_name GOAP_AIBrain

var world_update: Callable ## 世界状态更新方法 返回Dictionary
var available_actions: Array = [] ## 可用行为库 从中决策行动计划
var current_goals: Array = [] ## 当前目标 根据感知到的对象设置目标
var current_plan: Array = [] ## 当前行动计划

# 主决策方法
func decide_next_action() -> Dictionary:
	if not world_update:
		return {}
	var world_state = world_update.call()
	
	# 1. 选择最高优先级目标
	var active_goal = _select_goal(world_state)
	if not active_goal:
		return {}
	
	# 2. 生成行动计划
	if current_plan.is_empty() or not _validate_plan(active_goal):
		current_plan = _plan_actions(active_goal, world_state)
		if current_plan.is_empty():
			return {}
	
	# 3. 执行计划中的下一个动作
	var next_action = current_plan.pop_front()
	return next_action.action_generator.call(world_state)

# 私有方法
func _select_goal(world_state: Dictionary) -> GOAPGoal:
	var selected_goal: GOAPGoal = null
	var max_priority = -INF
	
	for goal in current_goals:
		if GOAPTool._state_satisfies(goal.conditions, world_state):
			continue
		if goal.priority > max_priority:
			max_priority = goal.priority
			selected_goal = goal
	
	return selected_goal

func _plan_actions(target_goal: GOAPGoal, start_state: Dictionary) -> Array:
	var planner = GOAPPlanner.new()
	return planner.plan(
		available_actions,
		start_state,
		target_goal.conditions
	)

func _validate_plan(target_goal: GOAPGoal) -> bool:
	var simulated_state = world_update.call()
	for action in current_plan:
		if not GOAPTool._state_satisfies(action.preconditions, simulated_state):
			return false
		simulated_state = GOAPTool._apply_effects(simulated_state, action.effects)
	return GOAPTool._state_satisfies(target_goal.conditions, simulated_state)

# 定义GOAP结构和辅助类
class GOAPPlanner:
	func plan(actions: Array, start_state: Dictionary, goal_conditions: Dictionary) -> Array:
		var open_set = []
		var came_from = {}
		var g_score = {}
		var f_score = {}
		
		var start_node = PlanNode.new(start_state, [], 0.0)
		open_set.append(start_node)
		g_score[start_node] = 0.0
		f_score[start_node] = _heuristic(start_state, goal_conditions)
		
		while not open_set.is_empty():
			open_set.sort_custom(func(a, b): return f_score.get(a, INF) < f_score.get(b, INF))
			var current = open_set.pop_front()
			
			if GOAPTool._state_satisfies(goal_conditions, current.state):
				return current.actions
			
			for action in actions:
				if GOAPTool._state_satisfies(action.preconditions, current.state):
					var new_state = GOAPTool._apply_effects(current.state, action.effects)
					var new_actions = current.actions.duplicate()
					new_actions.append(action)
					var new_cost = current.cost + action.cost
					
					var existing = open_set.filter(func(n): return n.state.hash() == new_state.hash())
					if existing.is_empty() or new_cost < g_score.get(existing[0], INF):
						var new_node = PlanNode.new(new_state, new_actions, new_cost)
						open_set.append(new_node)
						g_score[new_node] = new_cost
						f_score[new_node] = new_cost + _heuristic(new_state, goal_conditions)
		
		return []

	func _heuristic(state: Dictionary, goal: Dictionary) -> float:
		var unsatisfied = 0
		for key in goal:
			if state.get(key, null) != goal[key]:
				unsatisfied += 1
		return unsatisfied

	class PlanNode:
		var state: Dictionary
		var actions: Array
		var cost: float
		
		func _init(s: Dictionary, a: Array, c: float):
			state = s
			actions = a
			cost = c
		
		func hash() -> int:
			return var_to_str(state).hash()

class GOAPAction:
	var name: String
	var preconditions: Dictionary
	var effects: Dictionary
	var cost: float
	var action_generator: Callable
	
	func _init(n: String, pre: Dictionary, eff: Dictionary, c: float, gen: Callable):
		name = n
		preconditions = pre
		effects = eff
		cost = c
		action_generator = gen

class GOAPGoal:
	var name: String
	var priority: float
	var conditions: Dictionary
	
	func _init(n: String, p: float, c: Dictionary):
		name = n
		priority = p
		conditions = c

class GOAPTool:
	static func _state_satisfies(conditions: Dictionary, state: Dictionary) -> bool:
		for key in conditions:
			if state.has(key):
				if conditions[key] is Callable:
					return conditions[key].call(state[key])
				else:
					return state[key] == conditions[key]
			else:
				return false
		return true
	static func _apply_effects(state: Dictionary, effects: Dictionary) -> Dictionary:
		var new_state = state.duplicate()
		for key in effects:
			new_state[key] = effects[key]
		return new_state
