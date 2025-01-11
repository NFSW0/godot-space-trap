extends Resource
class_name TransportData


var portal1:NodePath
var portal2:NodePath
var target:NodePath


func _init(_portal1:NodePath, _portal2:NodePath, _target:NodePath) -> void:
	portal1 = _portal1
	portal2 = _portal2
	target = _target


## 数组化 可用于判断重复数据
func to_array() -> Array:
	return [portal1, portal2, target]


## 序列化方法
func serialize() -> Dictionary:
	return {
		"portal1": portal1,
		"portal2": portal2,
		"target": target
	}


## 实例化方法
static func instantiate(data:Dictionary = {}) -> TransportData:
	if data == null:
		return null
	var _portal1 = data.get("portal1", null)
	var _portal2 = data.get("portal2", null)
	var _target = data.get("target", null)
	if _portal1 == null or _portal2 == null:
		return null
	return TransportData.new(_portal1, _portal2, _target)
