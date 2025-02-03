@tool
extends Resource
class_name NT_GOAP_Environment


var name : String
var value : Variant


func _init(_name:String, _value:Variant) -> void:
	name = _name
	value = _value


## 数组化 可用于判断重复数据
func to_array() -> Array:
	return [name, value]


## 序列化方法
func serialize() -> Dictionary:
	return {
		"name": name,
		"value": value
	}


## 实例化方法
static func instantiate(data:Dictionary = {}) -> NT_GOAP_Environment:
	if data == null:
		return null
	var _name = data.get("name", null)
	var _value = data.get("value", null)
	return NT_GOAP_Environment.new(_name, _value)
