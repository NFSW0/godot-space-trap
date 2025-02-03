@tool
extends Resource
class_name NT_GOAP_Plan_Node


var state : Array
var actions : Array
var cost : int

# 构造函数
func _init(_state: Array, _actions: Array, _cost: int) -> void:
	state = _state
	actions = _actions
	cost = _cost
