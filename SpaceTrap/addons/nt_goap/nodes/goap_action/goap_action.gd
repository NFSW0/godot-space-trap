extends Node
class_name GOAPAction


@export var preconditions:Dictionary = {} ## 行动执行前需要满足的条件
@export var effects:Dictionary = {} ## 行动执行后的效果
@export var cost:int = 1 ## 行动的成本


## 行动
func execute(delta:float, entity):
	pass


## 检查当前状态是否满足行动的前置条件, 传入当前状态(全局+本地)
func is_achievable(current_state: Dictionary) -> bool:
	for key in preconditions:
		if not current_state.has(key) or current_state[key] != preconditions[key]:
			return false
	return true


## 应用效果, 传入本地状态, 返回应用后状态
func apply_effects(local_state: Dictionary) -> Dictionary:
	var new_state = local_state.duplicate()
	for key in effects:
		new_state[key] = effects[key]
	return new_state
