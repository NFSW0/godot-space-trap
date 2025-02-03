@tool
extends Resource
class_name NT_GOAP_Action


var name : String  ## 行动名称
var preconditions : Array  ## 行动条件
var effects : Array  ## 行动影响
var cost : int  ## 行动损耗


func _init(_name:String = "", _preconditions:Array = [], _effects:Array = [], _cost:int = 0) -> void:
	name = _name
	preconditions = _preconditions
	effects = _effects
	cost = _cost


## 数组化 可用于判断重复数据
func to_array() -> Array:
	var preconditions_array = []
	for precondition in preconditions:
		preconditions_array.append(precondition.to_array())

	var effects_array = []
	for effect in effects:
		effects_array.append(effect.to_array())

	return [name, preconditions_array, effects_array, cost]


## 序列化方法
func serialize() -> Dictionary:
	var preconditions_serialized = []
	for precondition in preconditions:
		preconditions_serialized.append(precondition.serialize())

	var effects_serialized = []
	for effect in effects:
		effects_serialized.append(effect.serialize())

	return {
		"name": name,
		"preconditions": preconditions_serialized,
		"effects": effects_serialized,
		"cost": cost
	}


## 实例化方法
static func instantiate(data:Dictionary = {}) -> NT_GOAP_Action:
	if data == null:
		return null
	
	var _name = data.get("name", "")
	var _preconditions = []
	for precondition_data in data.get("preconditions", []):
		var precondition = NT_GOAP_Environment.instantiate(precondition_data)
		if precondition == null:
			printerr("Failed to instantiate precondition.")
			return null
		_preconditions.append(precondition)

	var _effects = []
	for effect_data in data.get("effects", []):
		var effect = NT_GOAP_Environment.instantiate(effect_data)
		if effect == null:
			printerr("Failed to instantiate effect.")
			return null
		_effects.append(effect)

	var _cost = data.get("cost", 0)
	if _cost < 0:
		printerr("Invalid cost value: ", _cost)
		return null

	var action = NT_GOAP_Action.new(_name, _preconditions, _effects, _cost)
	if not action._validate():
		printerr("Validation failed for instantiated action.")
		return null
	
	return action


## 数据有效性检测
func _validate() -> bool:
	if name == "" or name.strip_edges() == "":
		printerr("Action name is invalid or empty.")
		return false
	if cost < 0:
		printerr("Action cost cannot be negative.")
		return false
	for precondition in preconditions:
		if not precondition is NT_GOAP_Environment:
			printerr("Invalid precondition detected.")
			return false
	for effect in effects:
		if not effect is NT_GOAP_Environment:
			printerr("Invalid effect detected.")
			return false
	return true
