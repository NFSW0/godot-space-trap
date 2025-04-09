# 标题场景 可添加互动元素
extends Node


@export var game_scene : PackedScene
@export var about_scene : PackedScene
@export var title_menu: Control
@onready var ui_manager : UIManager = get_node_or_null("/root/UIManager")


func _ready() -> void:
	if ui_manager:
		ui_manager.take_over_ui(title_menu, self, 0)


func _on_start_pressed() -> void:
	if game_scene:
		get_tree().change_scene_to_packed(game_scene)
	else:
		printerr("未添加游戏场景")


func _on_about_pressed() -> void:
	if about_scene:
		get_tree().change_scene_to_packed(about_scene)
	else:
		printerr("未添加关于场景")


func _on_quit_pressed() -> void:
	get_tree().quit()
