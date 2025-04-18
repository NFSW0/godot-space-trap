extends Control


const GameScene = "res://MAIN/2_game_scene/game_scene_2.tscn"
const TITLE_SCENE = "res://MAIN/1_title_scene/title_scene.tscn"


func _on_reborn_pressed() -> void:
	get_tree().change_scene_to_file(GameScene)
	UIManager.close_ui(self)


func _on_to_title_pressed() -> void:
	get_tree().change_scene_to_file(TITLE_SCENE)
	UIManager.close_ui(self)
