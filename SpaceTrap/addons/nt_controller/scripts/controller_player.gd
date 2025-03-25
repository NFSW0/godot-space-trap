## 玩家控制器类 用于从输入信息中获取行动指令 注意与项目>项目设置>输入映射同步
extends ControllerBase
class_name ControllerPlayer


## 返回{COMMAND_TYPE, Value}
func get_command() -> Dictionary:
	var command = {}
	
	var move_input = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	
	if move_input != Vector2.ZERO:
		command[COMMAND_TYPE.MOVE_TOWARD] = move_input
	
	if Input.is_action_just_pressed("attack"):
		command[COMMAND_TYPE.ATTACK] = Vector2()
	
	if Input.is_action_just_pressed("interact"):
		command[COMMAND_TYPE.INTERACT] = Vector2()
	
	if Input.is_action_pressed("defense"):
		command[COMMAND_TYPE.DEFENSE] = Vector2()
	
	return command
