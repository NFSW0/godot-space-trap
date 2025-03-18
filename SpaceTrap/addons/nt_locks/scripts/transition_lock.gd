## 转换锁 / 过渡锁 : 判定结果变化后解锁
class_name TransitionLock
extends RefCounted


var judge:Callable
var old_result


func _init(_judge: Callable) -> void:
	judge = _judge


func process() -> bool:
	return old_result == judge.call()
