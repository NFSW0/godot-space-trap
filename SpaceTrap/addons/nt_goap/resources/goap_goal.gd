# GOAP核心类：目标
extends Resource
class_name GOAPGoal


var priority: int = 0  # 基础优先级
var preconditions = {}  # 需要满足的条件
var desired_effects = {}  # 期望达成的效果


## 动态计算当前优先级（需要重载）
func calculate_priority(world_state: Dictionary) -> int:
	return priority


## 检查是否满足目标条件
func is_valid(world_state: Dictionary) -> bool:
	for key in preconditions:
		if world_state.get(key) != preconditions[key]:
			return false
	return true
