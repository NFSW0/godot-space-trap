## 维护本地环境
## 从行为库(子节点)中决策行动计划
extends Node
class_name GOAP


var desired_state: Dictionary = {} ## 期望状态(目标状态)
var local_state: Dictionary = {} ## 本地状态


var possible_actions: Array = [] ## 当前可用的行动
var action_plan: Array = [] ## 当前的行动计划


## 世界环境没有按期望的变化时或目标发生改变时调用 以重新规划行动
func update() -> void:
	var global_state = {} # TODO 获取全局环境
	var current_state = local_state.merged(global_state)
	possible_actions = get_possible_actions(current_state)
	
	# 异步规划
	await _plan_actions_astar_async(desired_state, current_state, get_children())


## 执行函数(应该在物理更新时调用) 
func execute(delta: float, entity):
	if not action_plan.size() > 0:
		return
	
	# 过滤出当前可执行的行动
	var current_actions = action_plan.filter(func(action): return action in possible_actions)
	
	# 执行每个行动
	for action in current_actions:
		if action.is_achievable(local_state):  # 检查行动是否仍然可以执行
			action.execute(delta, entity)
			local_state = action.apply_effects(local_state)  # 更新本地状态
	
	# 重新规划行动计划
	update()


## 异步包装函数
func _plan_actions_astar_async(goal_state: Dictionary, current_state: Dictionary, actions: Array) -> void:
	action_plan = await plan_actions_astar(goal_state, current_state, actions)


#region GOAP 功能函数
## 检查是否达成目标, 传入当前状态(本地+全局)
func achieved(current_state: Dictionary, target_state: Dictionary) -> bool:
	for key in target_state:
		if not current_state.has(key) or current_state[key] != target_state[key]:
			return false
	return true


## 筛选可用行为(排序:损耗低→高)
func get_possible_actions(current_state: Dictionary) -> Array:
	var possible_actions = []
	for action in get_children():
		if action.is_achievable(current_state):
			possible_actions.append(action)
	possible_actions.sort_custom(func(a, b): return a.cost < b.cost)
	return possible_actions


## GOAP 规划函数（使用 A* 算法，异步版本）
func plan_actions_astar(goal_state: Dictionary, current_state: Dictionary, actions: Array) -> Array:
	# 定义一个优先队列用于 A* 搜索
	var priority_queue = [] # 队列中的元素是一个字典：{"f": 总代价, "state": 当前状态, "plan": 已执行的行动列表, "cost": 累计成本}
	priority_queue.append({"f": 0, "state": current_state, "plan": [], "cost": 0})
	
	# 用于记录已经访问过的状态及其最小成本
	var visited_states = {}
	var max_iterations_per_frame = 50 # 每帧最多处理的节点数，防止卡顿
	var iterations = 0
	
	while priority_queue.size() > 0:
		# 每帧只处理一定数量的节点
		if iterations >= max_iterations_per_frame:
			await Engine.get_singleton("SceneTree").idle_frame # 让出控制权，等待下一帧
			iterations = 0
		
		# 取出优先队列中总代价最小的元素
		priority_queue.sort_custom(_sort_by_f) # 按照总代价 f 排序
		var node = priority_queue.pop_front()
		var state = node["state"]
		var plan = node["plan"]
		var cost = node["cost"]
		
		# 检查当前状态是否满足目标状态
		if _is_goal_achieved(state, goal_state):
			return plan
		
		# 如果当前状态已经访问过且成本更高，则跳过
		var state_key = _state_to_string(state)
		if visited_states.has(state_key) and visited_states[state_key] <= cost:
			continue
		visited_states[state_key] = cost
		
		# 遍历所有可用的行动
		for action in actions:
			# 检查当前行动是否可以执行
			if action.is_achievable(state):
				# 应用行动的效果，生成新的状态
				var new_state = action.apply_effects(state)
				# 创建新的计划列表，并添加当前行动
				var new_plan = plan.duplicate()
				new_plan.append(action)
				# 计算新的累计成本 g
				var new_cost = cost + action.cost
				# 计算启发式估计 h
				var heuristic = _heuristic_estimate(new_state, goal_state)
				# 总代价 f = g + h
				var total_cost = new_cost + heuristic
				# 将新状态和计划加入优先队列
				priority_queue.append({
					"f": total_cost,
					"state": new_state,
					"plan": new_plan,
					"cost": new_cost
				})
		
		iterations += 1
	
	# 如果队列为空且未找到解决方案，返回空数组
	return []
#endregion GOAP 功能函数

#region GOAP 辅助函数
## 自定义排序函数：按照字典中的 "f" 值升序排序
func _sort_by_f(a: Dictionary, b: Dictionary) -> bool:
	return a["f"] < b["f"]

## 启发函数：估计从当前状态到目标状态的代价
func _heuristic_estimate(current_state: Dictionary, goal_state: Dictionary) -> float:
	var estimate = 0
	for key in goal_state:
		if not current_state.has(key) or current_state[key] != goal_state[key]:
			estimate += 1 # 每个未满足的目标条件增加 1 的代价
	return estimate

## 辅助函数：检查当前状态是否满足目标状态
func _is_goal_achieved(current_state: Dictionary, goal_state: Dictionary) -> bool:
	for key in goal_state:
		if not current_state.has(key) or current_state[key] != goal_state[key]:
			return false
	return true

## 辅助函数：将状态字典转换为字符串，用于唯一标识状态
func _state_to_string(state: Dictionary) -> String:
	var keys = state.keys()
	keys.sort()
	var result = ""
	for key in keys:
		result += str(key) + ":" + str(state[key]) + ";"
	return result
#endregion GOAP 辅助函数
