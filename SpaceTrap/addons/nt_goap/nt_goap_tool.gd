class_name NT_GOAP_Tool


## 获取当前行为(为达成目标所需的直接行动)
static func get_current_actions(target_env: Array, current_env: Array, action_library: Array) -> Array:
	var possible_actions = get_possible_actions(current_env, action_library)
	var action_plan = generate_action_plan(target_env, current_env, action_library)
	var current_actions = action_plan.filter(func(action): return action in possible_actions)
	return current_actions


## 筛选可用行为(排序:损耗低→高)
static func get_possible_actions(current_env: Array, action_library: Array) -> Array:
	var possible_actions = []
	for action in action_library:
		if _are_preconditions_met(current_env, action.preconditions):
			possible_actions.append(action)
	possible_actions.sort_custom(func(a, b): return a.cost < b.cost)
	print("可用行为：", possible_actions.map(func(element):return element.to_array()))
	return possible_actions


## 生成行动计划
static func generate_action_plan(target_env: Array, current_env: Array, action_library: Array) -> Array:
	var action_plan = []
	
	# A* 搜索策略生成行动计划
	var open_list = []
	var closed_list = {}
	var start_node = NT_GOAP_Plan_Node.new(target_env, [], 0)
	open_list.append(start_node)
	
	while open_list.size() > 0:
		open_list.sort_custom(func(a, b): return a.cost < b.cost)  # 按成本排序
		var current_node = open_list.pop_front()
		var current_state = current_node.state
		
		# 决策完成条件：当前环境状态满足所需环境状态
		if _are_goals_met(current_state, current_env):
			action_plan = current_node.actions
			return action_plan
		
		for action in action_library:
			if _effects_satisfy_state(action.effects, current_state):
				var new_state = _update_plan_state(action.preconditions, action.effects, current_state.duplicate(true))
				var new_actions = [action] + current_node.actions
				var new_cost = current_node.cost + action.cost
				var new_node = NT_GOAP_Plan_Node.new(new_state, new_actions, new_cost)
				
				if not _state_in_closed_list(new_state, closed_list):
					open_list.append(new_node)
					closed_list[new_state] = true
	print("行动计划：", action_plan.map(func(element):return element.to_array()))
	return action_plan


#region 辅助方法
# 检查当前状态是否满足全局+本地环境
static func _are_goals_met(current_state: Array, environment: Array) -> bool:
	for goal in current_state:
		if not _is_condition_met_in_environment(goal, environment):
			return false
	return true
# 检查效果是否满足目标状态
static func _effects_satisfy_state(effects: Array, state: Array) -> bool:
	for effect in effects:
		if not _is_condition_met_in_environment(effect, state):
			return false
	return true
# 更新计划状态,移除效果,添加条件
static func _update_plan_state(preconditions: Array, effects: Array, state: Array) -> Array:
	for effect in effects:
		state = state.filter(func(env): return env.name != effect.name)
	return state + preconditions
# 检查状态是否已在关闭列表中
static func _state_in_closed_list(state: Array, closed_list: Dictionary) -> bool:
	for key in closed_list.keys():
		if _are_states_equal(key, state):
			return true
	return false
# 比较两个环境状态是否相同
static func _are_states_equal(state1: Array, state2: Array) -> bool:
	if state1.size() != state2.size():
		return false
	for i in range(state1.size()):
		if state1[i].name != state2[i].name or state1[i].value != state2[i].value:
			return false
	return true
# 检查行为条件是否满足
static func _are_preconditions_met(current_env: Array, preconditions: Array) -> bool:
	for precondition in preconditions:
		if not _is_condition_met_in_environment(precondition, current_env):
			return false
	return true
# 检查单个目标条件是否满足当前环境
static func _is_condition_met_in_environment(condition: NT_GOAP_Environment, environment: Array) -> bool:
	for state in environment:
		if state.name == condition.name and state.value == condition.value:
			return true
	return false
#endregion 辅助方法
