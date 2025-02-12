## 玩家控制器类 用于从输入信息中获取行动指令
extends ControllerBase
class_name ControllerPlayer


## 返回{COMMAND_TYPE, Value}
func get_command() -> Dictionary:
	var command = {}
	# 监听移动输入（WASD 或方向键）
	var move_input = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()
	if move_input != Vector2.ZERO:
		command[COMMAND_TYPE.MOVE_TOWARD] = move_input
	# 监听攻击输入（例如鼠标左键或空格键）
	if Input.is_action_just_pressed("attack"):
		command[COMMAND_TYPE.ATTACK] = true
	# 监听互动输入（例如 E 键）
	if Input.is_action_just_pressed("interact"):
		command[COMMAND_TYPE.INTERACT] = true
	# 监听防御输入（例如 Shift 键）
	if Input.is_action_pressed("defense"):
		command[COMMAND_TYPE.DEFENSE] = true
	return command
