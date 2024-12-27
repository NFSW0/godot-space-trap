extends Node
class_name _HitManager

class HitInfo:
	var node1:Node
	var node2:Node
	var normal:Vector2
	
	func _init(_node1:Node, _node2:Node, _normal:Vector2) -> void:
		node1 = _node1
		node2 = _node2
		normal = _normal

var event_list:Array[HitInfo] = []
var process_limit = 100


func append_hit_event(data:Dictionary):
	# 获取两个碰撞对象
	var node1 = get_node(data["node_path_1"])
	var node2 = get_node(data["node_path_2"])
	var normal = data["normal"]
	if node1 == null || node2 == null || normal == null:
		print("无效数据")
		return
	# 检测是否已有相同事件被添加
	var index = event_list.size() - 1
	for t in process_limit:
		if event_list[index].normal == normal:
			pass
		index -= 1
	# 添加待处理事件
	event_list.push_back(HitInfo.new(node1, node2, normal))


## 清理缓存
func clear_hit_event():
	event_list.clear()


## 结算碰撞事件
func _physics_process(_delta: float) -> void:
	pass


## 处理碰撞
## 两个都是动量体:弹性碰撞m1v1=m2v2，速度方向由软硬碰撞决定
## 一个是动量体:完全弹性碰撞
func _handle_hit(node1:Node, node2:Node, normal:Vector2):
	var type1 = node1.get("mass")
	var type2 = node2.get("mass")
	if type1 == null:
		_handle_single(node2, normal) # 处理node2
	elif type2 == null:
		_handle_single(node1, normal) # 处理node1
	else:
		_handle_double(node1, node2, normal, (type1 == type2)) # 处理双动量体碰撞


## 假设弹性0.9
## 则0.9倍的动量用于传递，0.1倍的动量用于质量损耗(造成伤害)
func _handle_single(node: Node, normal: Vector2):
	var node_mass:float = node.get("mass")
	var node_speed:float = node.get("speed")
	var node_direction:Vector2 = node.get("direction")
	var elasticity = node_speed / (node_speed + node_mass)
	var loss_ratio = 1 - elasticity
	var target_direction = _get_rebound_speed(node_direction, normal).normalized()
	node.set("speed", node_speed * elasticity)
	node.set("mass", node_mass * loss_ratio)
	node.set("direction", target_direction)


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
	
	# 计算物体1和物体2的动量 (动量 = 质量 * 速度)
	var node1_mv:float = node1_mass * node1_speed
	var node2_mv:float = node2_mass * node2_speed
	
	# 计算两个物体的总质量
	var total_mass:float = node1_mass + node2_mass
	
	# 计算相对速度 (绝对值)
	var relative_speed:float = abs(node1_speed - node2_speed)
	
	# 计算两个物体的总动量 (以相对速度为基础)
	var total_mv:float = total_mass * relative_speed
	
	# 计算弹性系数：两物体相对速度和总质量的比例
	var elasticity:float = relative_speed / (relative_speed + total_mass)
	
	# 计算能量损失比例：1 - 弹性系数
	var loss_ratio:float = 1 - elasticity
	
	# 计算损失的质量：损失的质量 = 损失比例 * 两物体中较小的质量
	var loss_mass:float = loss_ratio * min(node1_mass, node2_mass)
	
	# 更新两物体的质量，损失质量从每个物体的质量中扣除
	node1.set("mass", node1_mass - loss_mass)
	node2.set("mass", node2_mass - loss_mass)
	
	if rebound: # 弹性碰撞处理：碰撞后物体速度方向相反，动量均分
		# 根据总动量均分计算每个物体的速度
		node1.set("speed", total_mv / 2 / node1_mass)
		node2.set("speed", total_mv / 2 / node2_mass)
		
		# 更新物体1的速度方向：通过法线反弹计算新方向
		node1.set("direction", _get_rebound_speed(node1_direction, normal).normalized())
		
		# 更新物体2的速度方向：通过法线反弹计算新方向
		node2.set("direction", _get_rebound_speed(node2_direction, normal).normalized())
	else: # 非弹性碰撞处理：物体间速度分摊，速度方向相同
		# 根据物体2的动量计算物体1的新速度
		node1.set("speed", node1_speed - node2_mv / node1_mass)
		
		# 根据物体1的动量计算物体2的新速度
		node2.set("speed", node2_speed - node1_mv / node2_mass)
		
		# 统一物体1和物体2的速度方向为大质量物体的方向
		var dominant_direction: Vector2 = node1_direction if node1_mass >= node2_mass else node2_direction
		node1.set("direction", dominant_direction.normalized())
		node2.set("direction", dominant_direction.normalized())


## 计算完全反弹的矢量速度
func _get_rebound_speed(velocity:Vector2, normal:Vector2) -> Vector2:
	normal = normal.normalized() # 归一化
	var vn = velocity * normal # 点乘得到法线方向的速度
	var vt = velocity - vn # 减去法线速度得到切线速度
	return vt - vn # 切线速度与反向的法线速度相加得到反弹速度


## 对比两对无序数据是否相同
func _are_arrays_equal(array1: Array, array2: Array) -> bool:
	# 首先检查数组长度是否相同
	if array1.size() != array2.size():
		return false
	
	# 复制两个数组并进行排序
	var sorted_array1 = array1.duplicate()
	var sorted_array2 = array2.duplicate()
	
	sorted_array1.sort()  # 对第一个数组进行排序
	sorted_array2.sort()  # 对第二个数组进行排序

	# 比较两个排序后的数组是否相同
	return sorted_array1 == sorted_array2
