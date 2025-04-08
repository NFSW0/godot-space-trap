extends Node


@export var title_scene : PackedScene


func _ready() -> void:
	call_deferred("_to_title")


## 跳转到主菜单
func _to_title():
	get_tree().change_scene_to_packed(title_scene)
