extends UIBase


signal on_back_to_game_pressed
signal on_quit_to_title_pressed


func _on_back_to_game_pressed() -> void:
	on_back_to_game_pressed.emit()


func _on_quit_to_title_pressed() -> void:
	on_quit_to_title_pressed.emit()
