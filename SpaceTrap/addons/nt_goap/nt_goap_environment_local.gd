@tool
extends Control


signal add_environment(environment:NT_GOAP_Environment)
signal remove_environment(environment:NT_GOAP_Environment)


@onready var library_view: ItemList = %LibraryView


func update_view(environments:Array):
	library_view.clear()
	for environment in environments:
		library_view.add_environment_item(environment)


func _on_library_view_add_environment(environment: NT_GOAP_Environment) -> void:
	add_environment.emit(environment)


func _on_library_view_remove_environment(environment: NT_GOAP_Environment) -> void:
	remove_environment.emit(environment)
