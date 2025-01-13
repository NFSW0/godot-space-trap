extends Resource
class_name TransportingData


var portal1:NodePath
var portal2:NodePath
var targets:Array[NodePath] # 包含一个传送目标及其克隆体，用于判断[已有的]传送请求


func _init(_portal1:NodePath, _portal2:NodePath, _targets:Array[NodePath]) -> void:
	portal1 = _portal1
	portal2 = _portal2
	targets = _targets


## 数组化 可用于判断重复数据
func to_array() -> Array:
	return [portal1, portal2] + targets


## 序列化方法
func serialize() -> Dictionary:
	return {
		"portal1": portal1,
		"portal2": portal2,
		"targets": targets
	}


## 实例化方法
static func instantiate(data:Dictionary = {}) -> TransportingData:
	if not data or !data.has("portal1") or !data.has("portal2"):
		return null
	var _portal1 = data.get("portal1", null)
	var _portal2 = data.get("portal2", null)
	var _targets = data.get("targets", [])
	if _portal1 == null or _portal2 == null or !(_targets is Array):
		return null
	return TransportingData.new(_portal1, _portal2, _targets)
