extends Entity2D
class_name ControllableEntity2D


@export var animation_tree: AnimationTree ## 动画节点
@export var controller: ControllerBase: ## 控制器
	set(value):
		controller = value
var controllable = true ## 是否可控


## 过度到另一个动画 传入动画名称
func travel_animation(animation_name: String):
	if animation_tree:
		animation_tree.get("parameters/playback").travel(animation_name)


# 更新
func _physics_process(delta: float) -> void:
	if not controller or not controllable:
		return
	var cmd = controller.get_command()
	_execute_command(cmd)


# 执行行动指令
func _execute_command(command: Dictionary) -> void:
	for command_type:ControllerBase.COMMAND_TYPE in command:
		match command_type:
			_:
				push_warning("ignore command type: ", command_type)
