## 用于管理传送请求 分配传送任务 处理重复请求
## TODO 统一处理添加传送的请求和结束传送的请求，添加请求和结束请求都需要遍历全部进行中的任务，可能可以优化逻辑减少遍历次数
extends Node
class_name _PortalManager


var request_list:Array[TransportData] = []
var process_limit = 100 # 进程限制


var _transport_tasks:Array[TransportingData] = [] # 进行中的传送，记录克隆体，用于判断重复的传送请求，特别是因克隆体导致的叠加传送


# 请求-添加传送
func append_transport_request(data: Dictionary):
	var new_request = _create_transport_request(data)
	if new_request == null:
		return
	if _is_duplicate_request(new_request):
		return
	if _is_task_duplicate(new_request):
		return
	
	request_list.push_back(new_request)


# 请求-结束传送
func end_transport_request(data: Dictionary):
	var new_request = _create_transport_request(data)
	if new_request == null:
		return
	
	# 处理结束传送
	_process_end_transport_request(new_request)


# 清理缓存
func clear_hit_event():
	request_list.clear()



# 创建传送请求
func _create_transport_request(data: Dictionary) -> TransportData:
	var new_request = TransportData.instantiate(data)
	if new_request == null:
		return null
	return new_request

# 判断是否与现有请求重复
func _is_duplicate_request(new_request: TransportData) -> bool:
	var length = min(request_list.size(), process_limit)
	var slice_list = request_list.slice(-length)
	for transport_data: TransportData in slice_list:
		if Tool.are_arrays_equal(transport_data.to_array(), new_request.to_array()):
			return true
	return false

# 判断是否与现有任务重复
func _is_task_duplicate(new_request: TransportData) -> bool:
	for transporting_data: TransportingData in _transport_tasks:
		var portal_array1 = [transporting_data.portal1, transporting_data.portal2]
		var portal_array2 = [new_request.portal1, new_request.portal2]
		if Tool.are_arrays_equal(portal_array1, portal_array2) and transporting_data.targets.has(new_request.target):
			return true
	return false



# 判断任务是否匹配请求
func _is_matching_task(transporting_data: TransportingData, new_request: TransportData) -> bool:
	var portal_array1 = [transporting_data.portal1, transporting_data.portal2]
	var portal_array2 = [new_request.portal1, new_request.portal2]
	return Tool.are_arrays_equal(portal_array1, portal_array2) and transporting_data.targets[0] == new_request.target

# 处理结束传送逻辑
func _process_end_transport_request(new_request: TransportData):
	# 使用倒序索引遍历数组
	for i in range(_transport_tasks.size() - 1, -1, -1):
		var transporting_data: TransportingData = _transport_tasks[i]
		
		# 比较传送门数组
		if _is_matching_task(transporting_data, new_request):
			# 获取并检查节点
			_handle_end_transport(transporting_data, i)
			break

# 处理结束传送任务
func _handle_end_transport(transporting_data: TransportingData, task_index: int):
	var node = get_node_or_null(transporting_data.targets[0])
	var duplicate_node = get_node_or_null(transporting_data.targets[1])
	var portal = get_node_or_null(transporting_data.portal1)
	
	# 检查节点有效性
	if not node or not duplicate_node or not portal:
		return
	
	# 调用传送结束方法
	portal.erase_task(node, duplicate_node)
	
	# 从数组中移除目标
	_transport_tasks.remove_at(task_index)



# 结算传送
func _physics_process(_delta: float) -> void:
	_handle_transport_request()

# 处理传送(生成复制体，分配传送门，记录传送中数据)
func _handle_transport_request():
	var events_to_process = min(request_list.size(), process_limit)
	for i in range(events_to_process):
		var transport_data: TransportData = request_list.pop_front()
		# 处理传送任务
		_process_transport_data(transport_data)

# 处理每个传送数据
func _process_transport_data(transport_data: TransportData):
	var portal1 = transport_data.portal1
	var portal2 = transport_data.portal2
	var target = transport_data.target
	var node_portal1 = get_node_or_null(portal1)
	var node_portal2 = get_node_or_null(portal2)
	var node_target = get_node_or_null(target)
	
	# 检查节点有效性
	if not node_portal1 or not node_portal2 or not node_target:
		return
	
	# 创建目标克隆体并进行传送
	var node_target_duplicate = _create_target_duplicate(node_target)
	_add_transport_task(portal1, portal2, target, node_target_duplicate)
	
	# 添加传送任务
	node_portal1.add_task(node_target, node_target_duplicate)

# 创建目标克隆体
func _create_target_duplicate(node_target: Node) -> Node:
	var node_target_duplicate = node_target.duplicate()
	node_target_duplicate.name = node_target.name + "_duplicate"
	node_target_duplicate.set("visible", false)
	node_target_duplicate.set("script", null)
	#node_target_duplicate.material = (node_target_duplicate.material as ShaderMaterial).duplicate()
	node_target.get_parent().add_child(node_target_duplicate)
	return node_target_duplicate

# 添加传送任务
func _add_transport_task(portal1: String, portal2: String, target: String, node_target_duplicate: Node):
	_transport_tasks.append(TransportingData.new(portal1, portal2, [target, node_target_duplicate.get_path()]))
