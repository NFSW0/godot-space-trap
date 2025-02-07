extends CharacterBody2D
class_name Entity


@export var entity_id:int = 0
@export var direction:Vector2 = Vector2()
@export var speed:float = 0
@export var mass:float = 1:
	set(value):
		mass = value
		set("scale",Vector2(value/1, value/1))
		if mass < 0.1:
			call_deferred("queue_free")


@export var action_library_resource: JSON # 行为库文件(需解析)


var target_environment: Dictionary = {} # 目标环境状态
var current_environment: Dictionary = {} # 当前环境状态
var action_library: Array = [] # 行为库


# 初始化行为库
func _ready() -> void:
	if action_library_resource:
		#var content = action_library_resource.get_as_text()
		var parsed_data = action_library_resource.data
		if parsed_data is Array:
			action_library = parsed_data.map(func(element): return NT_GOAP_Action.instantiate(element))


# 更新行为
func _physics_process(delta: float) -> void:
	var current_actions = NT_GOAP_Tool.get_current_actions(_environment_to_array(target_environment), _environment_to_array(current_environment), action_library)
	for action in current_actions:
		call(action.name, delta)


# 字典转数组
func _environment_to_array(environment: Dictionary) -> Array:
	var environment_array = []
	for key in environment:
		environment_array.append(NT_GOAP_Environment.new(key, environment[key]))
	return environment_array
