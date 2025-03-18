## 碰撞处理器
extends Node
class_name _HitManager


var request_list:Array[HitData] = [] # 待处理的碰撞请求
var process_limit = 100 # 最大批处理量


## 添加待处理碰撞
func append_hit_event(data:Dictionary):
	var new_request = HitData.instantiate(data)
	if new_request == null:
		return
	# 剔除重复数据
	var length = min(request_list.size(), process_limit)
	var slice_list = request_list.slice(-length)
	for hitdata: HitData in slice_list:
		if Tool.are_arrays_equal(hitdata.to_array(), new_request.to_array()):
			return
	# 添加待处理事件
	request_list.push_back(new_request)


## 清理缓存
func clear_hit_event():
	request_list.clear()


## 结算碰撞事件（批处理）
func _physics_process(_delta: float) -> void:
	var events_to_process = min(request_list.size(), process_limit)
	for i in range(events_to_process):
		var hitData: HitData = request_list.pop_front()
		var node1 = get_node_or_null(hitData.nodepath1)
		var node2 = get_node_or_null(hitData.nodepath2)
		if node1 and node2:
			_handle_hit(node1, node2, hitData.normal)


## 处理碰撞
func _handle_hit(node1: Node, node2: Node, normal: Vector2):
	var has_mass1 := node1.get("mass") != null
	var has_mass2 := node2.get("mass") != null
	
	if not has_mass1 and not has_mass2:
		return
	elif not has_mass2:
		_handle_single(node1, normal)
	elif not has_mass1:
		_handle_single(node2, normal)
	else:
		_handle_double(node1, node2, normal)


## 处理单体碰撞
func _handle_single(node: Node, normal: Vector2):
	var velocity := _get_valid_velocity(node)
	if not velocity:
		return
	
	var speed := velocity.length()
	var loss_mass := speed / 100
	
	var rebound_velocity := _get_rebound_speed(velocity, normal).normalized() * speed
	
	_subtract_mass(node, loss_mass)
	node.set("velocity", rebound_velocity)


## 处理双体碰撞
func _handle_double(node1: Node, node2: Node, normal: Vector2):
	var vel1 := _get_valid_velocity(node1)
	var vel2 := _get_valid_velocity(node2)
	if not vel1 or not vel2:
		return
	
	var normal_norm := normal.normalized()
	var vel1_along := _get_velocity_component(vel1, normal_norm)
	var vel2_along := _get_velocity_component(vel2, normal_norm)
	
	var relative_speed := vel1_along.distance_to(vel2_along)
	var loss_mass := relative_speed / 100
	
	# 更新质量
	_subtract_mass(node1, loss_mass)
	_subtract_mass(node2, loss_mass)
	
	# 计算新速度分量
	var new_vel1 = (vel1 - vel1_along) + vel1_along.normalized() * relative_speed / 2
	var new_vel2 = (vel2 - vel2_along) + vel2_along.normalized() * relative_speed / 2
	
	node1.set("velocity", new_vel1)
	node2.set("velocity", new_vel2)


#region 辅助方法
## 获取有效速度（类型检查）
func _get_valid_velocity(node: Node) -> Vector2:
	var velocity = node.get("velocity")
	return velocity if velocity is Vector2 else Vector2()

## 计算沿法线方向的速度分量
func _get_velocity_component(velocity: Vector2, normal: Vector2) -> Vector2:
	return velocity.dot(normal) * normal

## 质量减少操作
func _subtract_mass(node: Node, amount: float) -> void:
	var mass = node.get("mass")
	if mass is float:
		node.set("mass", mass - amount)

## 计算完全反弹速度
func _get_rebound_speed(velocity: Vector2, normal: Vector2) -> Vector2:
	var normal_norm = normal.normalized()
	return velocity - 2 * velocity.dot(normal_norm) * normal_norm
#endregion 辅助方法
