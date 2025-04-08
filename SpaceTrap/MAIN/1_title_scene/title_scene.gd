extends Node


@onready var ui_manager : UIManager = get_node_or_null("/root/UIManager")
@onready var title_menu: Control = $TitleMenu


func _ready() -> void:
	if ui_manager:
		#ui_manager.open_ui("title_menu", self)
		ui_manager.take_over_ui(title_menu, self)


func _on_quit_pressed() -> void:
	get_tree().quit()
