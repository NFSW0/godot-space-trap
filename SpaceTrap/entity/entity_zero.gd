## 空节点, 用于处理意外情况
extends Node
class_name EntityZero

func _ready() -> void:
	queue_free()
