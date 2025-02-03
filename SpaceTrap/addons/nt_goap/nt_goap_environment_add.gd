@tool
extends Control


signal add_environment(environment:NT_GOAP_Environment)


@onready var environment_name: LineEdit = %Name
@onready var tab: TabContainer = %Tab
@onready var bool_value: CheckButton = %BoolValue
@onready var num_value: SpinBox = %NumValue
@onready var x_value: SpinBox = %XValue
@onready var y_value: SpinBox = %YValue


func _on_add_pressed() -> void:
	var value = null
	match tab.current_tab:
		0:
			value = bool_value.button_pressed
		1:
			value = num_value.value
		2:
			value = [x_value.value, y_value.value]
	add_environment.emit(NT_GOAP_Environment.new(environment_name.text, value))


func _on_option_item_selected(index: int) -> void:
	tab.current_tab = index
