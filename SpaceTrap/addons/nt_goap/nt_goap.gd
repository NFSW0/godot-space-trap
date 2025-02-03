@tool
extends EditorPlugin


const MainPanel = preload("res://addons/nt_goap/nt_goap_interface.tscn")
const AUTOLOAD_NAME = "NT_GOAP_Manager"
const AUTOLOAD_FILE = "res://addons/nt_goap/nt_goap_manager.gd"


var main_panel_instance


func _enter_tree():
	# The autoload can be a scene or script file.
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_FILE)
	
	main_panel_instance = MainPanel.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)


func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
	
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name():
	return "NT_GOAP"


func _get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
