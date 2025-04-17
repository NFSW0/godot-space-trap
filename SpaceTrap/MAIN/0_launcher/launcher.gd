extends Node


@export var title_scene : PackedScene
@onready var audio_manager : AudioManager = get_node_or_null("/root/AudioManager")


func _ready() -> void:
	audio_manager.play_bgm("one_way_ticket")
	call_deferred("_to_title")


## 跳转到主菜单
func _to_title():
	get_tree().change_scene_to_packed(title_scene)
	#Dialogic.Styles.load_style("BubbleText")
	#Dialogic.start("DialogAtfterGuide")
