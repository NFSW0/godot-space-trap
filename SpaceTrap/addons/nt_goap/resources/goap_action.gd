extends Resource
# GOAP核心类：行动
class_name GOAPAction


var cost: float = 1.0  # 基础行动成本
var preconditions = {}  # 前提条件
var effects = {}        # 执行后的效果
var target = null      # 行动目标（可选）


# 检查前提条件是否满足
func check_preconditions(world_state: Dictionary) -> bool:
	for key in preconditions:
		if world_state.get(key) != preconditions[key]:
			return false
	return true


# 执行行动（需要重载）
func perform(actor) -> Dictionary:
	return {"status": "running"}
