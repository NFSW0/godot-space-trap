extends Entity2D
class_name ControllableEntity2D


@export var controller: ControllerBase = ControllerAI.new(): ## 控制器
	set(value):
		controller = value
@export var controllable = true ## 是否可控 攻击和受击中存在失控时间


# 更新
func _physics_process(delta: float) -> void:
	if not controller or not controllable:
		return
	var cmd = controller.get_command()
	_execute_command(cmd)


# 执行行动指令(需要覆写)
func _execute_command(command: Dictionary) -> void:
	for command_type:ControllerBase.COMMAND_TYPE in command:
		match command_type:
			_:
				push_warning("ignore command type: ", command_type)
