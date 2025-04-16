extends Node


const TITLE_SCENE = "res://MAIN/1_title_scene/title_scene.tscn"
const WORLD_SCENE = "res://world/world.tscn"
@onready var ui_manager : UIManager = get_node_or_null("/root/UIManager")
@onready var entity_manager : _EntityManager = get_node_or_null("/root/EntityManager")


func _ready() -> void:
	if entity_manager:
		# 设置多人实体承载节点
		entity_manager.update_spawn_path($Node2D/Entities.get_path())


func _unhandled_input(event: InputEvent) -> void:
	if event.as_text() == "Escape":
		if not ui_manager:
			return
		var game_menu = ui_manager.open_ui("game_menu", self)
		if game_menu and game_menu.has_signal("on_back_to_game_pressed"):
			game_menu.connect("on_back_to_game_pressed", func():ui_manager.close_ui(game_menu))
		if game_menu and game_menu.has_signal("on_quit_to_title_pressed"):
			game_menu.connect("on_quit_to_title_pressed", func():get_tree().change_scene_to_file(TITLE_SCENE))


# 教程结束
func _on_level_0_end_teach() -> void:
	$Node2D/Level0.queue_free()
	$Node2D.add_child((load(WORLD_SCENE) as PackedScene).instantiate())
