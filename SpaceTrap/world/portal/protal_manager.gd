extends Node
class_name _ProtalManager


var request_list:Array[TransportData] = []
var process_limit = 100 # 进程限制


var _underway_tasks:Array[TransportingData] = [] # 进行中的传送，用于判断重复的传送请求


## 添加传送请求
func append_transport_request(data:Dictionary):
	var new_request = TransportData.instantiate(data)
	if new_request == null:
		return
	# 剔除重复数据
	var length = min(request_list.size(), process_limit)
	var slice_list = request_list.slice(-length)
	for hitdata: TransportData in slice_list:
		if Tool.are_arrays_equal(hitdata.to_array(), new_request.to_array()):
			return
	# 添加待处理事件
	request_list.push_back(new_request)


## 清理缓存
func clear_hit_event():
	request_list.clear()


## 移除传送任务
func earse_transport_task():
	pass


## 结算传送
func _process(delta: float) -> void:
	var events_to_process = min(request_list.size(), process_limit)
	for i in range(events_to_process):
		var transport_data: TransportData = request_list.pop_front()
		var portal1 = get_node_or_null(transport_data.portal1)
		var portal2 = get_node_or_null(transport_data.portal2)
		var target = get_node_or_null(transport_data.target)
		if portal1 and portal2 and target:
			_handle_transport(portal1, portal2, target)


## 处理传送(生成复制体，分配传送门，记录传送中数据)
func _handle_transport(portal1, portal2, target):
	pass


## 添加传送任务
func _append_transport_task():
	pass
