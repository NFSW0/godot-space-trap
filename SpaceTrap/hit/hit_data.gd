extends Resource
class_name HitData


var nodepath1:NodePath
var nodepath2:NodePath
var normal:Vector2


func _init(_nodepath1:NodePath, _nodepath2:NodePath, _normal:Vector2) -> void:
	nodepath1 = _nodepath1
	nodepath2 = _nodepath2
	normal = _normal


## 数组化 可用于判断重复数据
func to_array() -> Array:
	return [nodepath1, nodepath2, normal]


## 序列化方法
func serialize() -> Dictionary:
	return {
		"nodepath1": nodepath1,
		"nodepath2": nodepath2,
		"normal": normal
	}


## 实例化方法
static func instantiate(data:Dictionary = {}) -> HitData:
	if data == null:
		return null
	var _nodepath1 = data.get("nodepath1", null)
	var _nodepath2 = data.get("nodepath2", null)
	var _normal = data.get("normal", null)
	if _nodepath1 == null or _nodepath2 == null:
		return null
	return HitData.new(_nodepath1, _nodepath2, _normal)
