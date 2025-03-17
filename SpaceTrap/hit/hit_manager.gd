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
func _handle_hit(node1:Node, node2:Node, normal:Vector2):
	var type1 = node1.get("mass")
	var type2 = node2.get("mass")
	if type1 == null and type2 == null:
		return
	if type1 == null or type2 == null:
		_handle_single(node1 if type2 == null else node2, normal)
	else:
		_handle_double(node1, node2, normal, (type1 == type2))


## 处理单体碰撞
func _handle_single(node: Node, normal: Vector2):
	var node_mass:float = node.get("mass")
	
	var node_velocity = node.get("velocity")
	if not node_velocity or not node_velocity is Vector2:
		return
	
	var node_speed:float = node_velocity.length()
	var node_direction:Vector2 = node_velocity.normalized()
	
	var loss_mass = node_speed # 损失量与速度大小成正比
	var target_direction = _get_rebound_speed(node_direction, normal).normalized()
	
	node.set("mass", node_mass - loss_mass)
	node.set("velocity", target_direction * node_speed)


## 假设弹性0.9
## 则0.9倍的动量用于传递，0.1倍的低质量体的动量用于损耗
func _handle_double(node1: Node, node2: Node, normal: Vector2, rebound: bool):
	# 获取物体1的质量、速度和方向
	var node1_mass:float = node1.get("mass")
	var node1_speed:float = node1.get("speed")
	var node1_direction:Vector2 = node1.get("direction")

	# 获取物体2的质量、速度和方向
	var node2_mass:float = node2.get("mass")
	var node2_speed:float = node2.get("speed")
	var node2_direction:Vector2 = node2.get("direction")
	
	# 计算动量和相对速度
	var node1_mv:float = node1_mass * node1_speed
	var node2_mv:float = node2_mass * node2_speed
	var total_mass:float = node1_mass + node2_mass
	var relative_speed:float = abs(node1_speed - node2_speed)
	
	# 弹性和损失比例计算
	var elasticity:float = relative_speed / (relative_speed + total_mass)
	var loss_ratio:float = 1 - elasticity
	var loss_mass:float = loss_ratio * min(node1_mass, node2_mass)
	
	# 更新两物体的质量，损失质量从每个物体的质量中扣除
	node1.set("mass", node1_mass - loss_mass)
	node2.set("mass", node2_mass - loss_mass)
	
	if rebound:
		# 弹性碰撞：反向速度，动量均分
		var total_mv:float = total_mass * relative_speed
		node1.set("speed", total_mv / 2 / node1_mass)
		node2.set("speed", total_mv / 2 / node2_mass)
		
		# 更新方向
		node1.set("direction", _get_rebound_speed(node1_direction, normal).normalized())
		node2.set("direction", _get_rebound_speed(node2_direction, normal).normalized())
	else:
		# 非弹性碰撞：速度分摊，方向相同
		node1.set("speed", node1_speed - node2_mv / node1_mass)
		node2.set("speed", node2_speed - node1_mv / node2_mass)
		
		# 统一速度方向
		var dominant_direction: Vector2 = node1_direction if node1_mass >= node2_mass else node2_direction
		node1.set("direction", dominant_direction.normalized())
		node2.set("direction", dominant_direction.normalized())


#region 辅助方法
## 计算完全反弹的矢量速度
func _get_rebound_speed(velocity:Vector2, normal:Vector2) -> Vector2:
	normal = normal.normalized().abs() # 归一化后统一符号
	var vn = velocity * normal
	return velocity - 2 * vn
#endregion 辅助方法
