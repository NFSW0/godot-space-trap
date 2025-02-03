# TODO 重复环境检测与处理
# TODO 行为库按照损耗从小到大排序，目的是在生成行动计划时永远优先低损耗的行动
@tool
extends Control
class_name _NT_GOAP_Manager


## 生成行动计划, 传入【目标环境、当前环境、行为库】, 返回【行动计划】
static func generate_action_plan(target_env: Array, current_env: Array, action_lib: Array) -> Array:
	var action_possible = []
	var action_plan = []

	# 筛选出满足前置条件的可用行为
	for action in action_lib:
		if _are_preconditions_met(current_env, action.preconditions):
			action_possible.append(action)
	
	# 按照损耗从小到大排序
	action_possible.sort_custom(func(a, b): return a.cost < b.cost)

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
		
		for action in action_possible:
			if _effects_satisfy_state(action.effects, current_state):
				var new_state = _update_plan_state(action.preconditions, action.effects, current_state.duplicate(true))
				var new_actions = [action] + current_node.actions
				var new_cost = current_node.cost + action.cost
				var new_node = NT_GOAP_Plan_Node.new(new_state, new_actions, new_cost)
				
				if not _state_in_closed_list(new_state, closed_list):
					open_list.append(new_node)
					closed_list[new_state] = true
	
	return action_plan


#region 插件内部方法
var environment_library: Array = [] ## 环境状态库
var action_library: Array = [] ## 行为库

var environment_global: Array = [] ## 全局环境状态
var environment_local: Array = [] ## 本地环境状态
var action_possible: Array = [] ## 可用行为

var environment_target: Array = [] ## 目标环境状态
var action_plan: Array = [] ## 行动计划

# 当全局或本地环境状态变化时调用
func on_environment_changed() -> void:
	_update_possible_actions()
	_update_action_plan()

# 当可用行为变化时调用
func on_possible_actions_changed() -> void:
	_update_action_plan()

# 根据全局环境状态和本地环境状态从行为库中筛选出可用行为
func _update_possible_actions() -> void:
	action_possible.clear()
	for action in action_library:
		if _are_preconditions_met(environment_global + environment_local, action.preconditions):
			action_possible.append(action)

# 使用反向搜索（A*算法）根据目标环境状态和行为库决策行动计划
func _update_action_plan() -> void:
	action_plan.clear()
	var open_list = []
	var closed_list = {}
	var start_node = NT_GOAP_Plan_Node.new(environment_target, [], 0)
	open_list.append(start_node)
	while open_list.size() > 0:
		open_list.sort_custom(func(a, b): return a.cost < b.cost) # 按成本排序
		var current_node = open_list.pop_front()
		var current_state = current_node.state
		
		# 决策完成条件：当前环境状态满足所需环境状态
		if _are_goals_met(current_state, environment_global + environment_local):
			action_plan = current_node.actions
			return
		
		for action in action_library:
			# 有效行为条件：行为效果是所需环境状态的一部分
			if _effects_satisfy_state(action.effects, current_state):
				var new_state = _update_plan_state(action.preconditions, action.effects, current_state.duplicate(true))
				var new_actions = [action] + current_node.actions
				var new_cost = current_node.cost + action.cost
				var new_node = NT_GOAP_Plan_Node.new(new_state, new_actions, new_cost)
				# 避免重复节点
				if not _state_in_closed_list(new_state, closed_list):
					open_list.append(new_node)
					closed_list[new_state] = true
#endregion 插件内部方法


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

## 检查当前状态是否满足全局+本地环境
#func _are_goals_met(current_state: Array, environment: Array) -> bool:
	#for goal in current_state:
		#if not _is_condition_met_in_environment(goal, environment):
			#return false
	#return true
## 检查效果是否满足目标状态
#func _effects_satisfy_state(effects: Array, state: Array) -> bool:
	#for effect in effects:
		#if not _is_condition_met_in_environment(effect, state):
			#return false
	#return true
## 更新计划状态,移除效果,添加条件
#func _update_plan_state(preconditions: Array, effects: Array, state: Array) -> Array:
	#for effect in effects:
		#state = state.filter(func(env): return env.name != effect.name)
	#return state + preconditions
## 检查状态是否已在关闭列表中
#func _state_in_closed_list(state: Array, closed_list: Dictionary) -> bool:
	#for key in closed_list.keys():
		#if key == state:
			#return true
	#return false
## 检查单个目标条件是否满足当前环境
#func _is_condition_met_in_environment(condition: NT_GOAP_Environment, environment: Array) -> bool:
	#for state in environment:
		#if state.name == condition.name and state.value == condition.value:
			#return true
	#return false
## 检查行为条件是否满足
#func _are_preconditions_met(preconditions: Array) -> bool:
	#for precondition in preconditions:
		#if not _is_condition_met(precondition):
			#return false
	#return true
## 检查单个环境条件是否满足
#func _is_condition_met(condition: NT_GOAP_Environment) -> bool:
	#for state in environment_global + environment_local:
		#if state.name == condition.name and state.value == condition.value:
			#return true
	#return false
#endregion 辅助方法
