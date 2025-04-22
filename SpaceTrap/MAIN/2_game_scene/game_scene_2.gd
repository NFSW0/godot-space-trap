extends Node


const TITLE_SCENE = "res://MAIN/1_title_scene/title_scene.tscn"
const WORLD_SCENE = "res://world/world.tscn"
@onready var ui_manager : UIManager = get_node_or_null("/root/UIManager")
@onready var entity_manager : _EntityManager = get_node_or_null("/root/EntityManager")


func _ready() -> void:
	$Node2D/Entities/Dummy/Camera2D/SubViewportContainer/SubViewport.world_2d = get_tree().root.world_2d
	get_tree().root.set_canvas_cull_mask_bit(5, false)
	var material = $Node2D/Entities/Dummy/Camera2D/SubViewportContainer.get("material")
	var image_multiplier = material.get("shader_parameter/image_multiplier")
	var tween = create_tween()
	tween.tween_property(image_multiplier, "width", 64.0, 2.0 )
	tween.parallel().tween_property(image_multiplier, "height", 64.0, 2.0 )
	Dialogic.signal_event.connect(on_chat_end)
	if entity_manager:
		# 设置多人实体承载节点
		entity_manager.update_spawn_path($Node2D/Entities.get_path())


func on_chat_end(arg: String):
	if arg == "End":
		var material = $Node2D/Entities/Dummy/Camera2D/SubViewportContainer.get("material")
		var image_multiplier = material.get("shader_parameter/image_multiplier")
		var tween = create_tween()
		tween.tween_property(image_multiplier, "width", 1.0, 2.0 )
		tween.parallel().tween_property(image_multiplier, "height", 1.0, 2.0 )
		tween.tween_callback(func():$Node2D/Entities/Dummy/Camera2D/SubViewportContainer.queue_free())


func _process(_delta: float) -> void:
	# 获取 Dummy 节点
	var dummy = get_node_or_null("Node2D/Entities/Dummy")
	# 获取 Camera2D 节点
	var camera = get_node_or_null("Node2D/Entities/Dummy/Camera2D/SubViewportContainer/SubViewport/Camera2D")
	# 检查节点是否存在
	if dummy and camera:
		# 确保两个节点都存在时才进行赋值
		camera.position = dummy.position

func _unhandled_input(event: InputEvent) -> void:
	if event.as_text() == "Escape":
		if not ui_manager:
			return
		var game_menu = ui_manager.open_ui("game_menu", self)
		if game_menu and game_menu.has_signal("on_back_to_game_pressed"):
			game_menu.connect("on_back_to_game_pressed", func():ui_manager.close_ui(game_menu))
		if game_menu and game_menu.has_signal("on_quit_to_title_pressed"):
			game_menu.connect("on_quit_to_title_pressed", func():get_tree().change_scene_to_file(TITLE_SCENE))
