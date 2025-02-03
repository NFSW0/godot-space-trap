@tool
extends Control


signal add_action(action:NT_GOAP_Action)


@onready var preconditions_view: ItemList = %PreconditionsView
@onready var effects_view: ItemList = %EffectsView
@onready var action_name_input: LineEdit = %ActionNameInput


var preconditions : Array = []
var effects : Array = []


func _reflash():
	preconditions_view.clear()
	effects_view.clear()
	for environment in preconditions:
		preconditions_view.add_environment_item(environment)
	for environment in effects:
		effects_view.add_environment_item(environment)


func _on_add_pressed() -> void:
	if action_name_input.text.is_empty() or effects.is_empty():
		print("请保证【行为名称】和【行动效果】不为空")
		return
	var new_action = NT_GOAP_Action.new(action_name_input.text, preconditions.duplicate(), effects.duplicate())
	add_action.emit(new_action)


func _on_preconditions_view_add_environment(environment: NT_GOAP_Environment) -> void:
	preconditions.append(environment)
	_reflash()
func _on_preconditions_view_remove_environment(environment: NT_GOAP_Environment) -> void:
	preconditions.erase(environment)
	_reflash()


func _on_effects_view_add_environment(environment: NT_GOAP_Environment) -> void:
	effects.append(environment)
	_reflash()
func _on_effects_view_remove_environment(environment: NT_GOAP_Environment) -> void:
	effects.erase(environment)
	_reflash()
