extends Node


const TITLE_SCENE = "res://MAIN/1_title_scene/title_scene.tscn"
@export var control: Control
@export var color_rect: ColorRect
@onready var ui_manager : UIManager = get_node_or_null("/root/UIManager")

func _ready() -> void:
	if ui_manager:
		ui_manager.take_over_ui(control, self, 0)
	var tween = color_rect.create_tween()
	tween.tween_property(color_rect, "color", Color(0,0,0,1), 0.5)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(TITLE_SCENE)
