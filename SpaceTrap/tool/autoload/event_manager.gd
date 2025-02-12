extends Node
class_name EventManager


# 字典用于存储事件及其对应的回调函数列表
var _event_listeners: Dictionary = {}


## 注册事件监听器
func register_event(event_name: String, callback: Callable) -> void:
	if not _event_listeners.has(event_name):
		_event_listeners[event_name] = []
	
	# 检查是否已经注册过该回调函数，避免重复注册
	if not _event_listeners[event_name].has(callback):
		_event_listeners[event_name].append(callback)


## 触发事件
func trigger_event(event_name: String, data: Variant = null) -> void:
	if _event_listeners.has(event_name):
		for callback in _event_listeners[event_name]:
			callback.call(data)


## 注销事件监听器
func unregister_event(event_name: String, callback: Callable) -> void:
	if _event_listeners.has(event_name):
		_event_listeners[event_name].erase(callback)
		
		# 如果没有监听器了，删除该事件
		if _event_listeners[event_name].size() == 0:
			_event_listeners.erase(event_name)


## 清除所有事件监听器
func clear_all_events() -> void:
	_event_listeners.clear()
