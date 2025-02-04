extends CharacterBody2D
class_name Entity


var target_environment: Dictionary = {}
var current_environment: Dictionary = {}
var action_library: Array = []


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	var current_actions = NT_GOAP_Tool.get_current_actions(target_environment.values(), current_environment.values(), action_library)
	for action in current_actions:
		call(action.name, delta)
