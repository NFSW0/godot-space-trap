extends Node
class_name _ProtalManager


var request_list:Array[TransportData] = []
var process_limit = 100 # 进程限制


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
