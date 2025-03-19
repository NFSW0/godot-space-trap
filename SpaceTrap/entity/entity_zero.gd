## 空节点 用于处理意外情况 多人spawn节点要求返回非空节点
extends Node
class_name EntityZero

func _ready() -> void:
	queue_free()
