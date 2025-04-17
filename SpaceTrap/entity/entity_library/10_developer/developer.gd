## 开发者角色
#class_name Developer
extends ControllableEntity2D


func _ready() -> void:
	Dialogic.signal_event.connect(dialog_event1)
	_dialog_to_end()


func _dialog_to_end():
	pass
	var layout = Dialogic.start("DialogAtfterGuide") # 开启对话
	if layout.has_method("register_character"):
		layout.register_character(load("res://dialogic/characters/Developer.dch"), $".")


func dialog_event1(arg: String):
	if arg == "1":
		print("对话事件1")
