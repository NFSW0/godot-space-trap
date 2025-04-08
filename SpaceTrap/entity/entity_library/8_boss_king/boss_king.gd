## 首领-君王
#class_name King
extends ControllableEntity2D


var attack_range : float = 100 ## 攻击距离


#region 动画
@export var animation_tree: AnimationTree ## 动画节点
## 过渡到另一个动画 传入动画名称
func travel_animation(animation_name: String, reset_on_teleport: bool = true):
	if animation_tree:
		animation_tree.set("parameters/%s/blend_position" % animation_name, velocity.normalized())
		animation_tree.get("parameters/playback").travel(animation_name, reset_on_teleport)
#endregion 动画



#region 智能-决策
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
			{"target_position": func(v): return position.distance_to(v) > attack_range if v else false},
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
			func(state): return {ControllerBase.COMMAND_TYPE.ATTACK: state["target"].get("position")}
		)
	)
	controller.set("ai_brain", ai_brain)


# 更新本地状态条件
func _update_local_state() -> Dictionary:
	var local_state = {}
	
	var target = _perceptual()
	if not target: return local_state
	local_state["target"] = target
	
	var target_position = target.get("position")
	if not target_position: return local_state
	local_state["target_position"] = target_position
	
	var target_in_range = position.distance_to(target_position) < attack_range
	local_state["target_in_range"] = target_in_range
	
	return local_state
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
