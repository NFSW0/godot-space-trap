## AI控制器类 用于从数据信息中生成行动指令
extends ControllerBase
class_name ControllerAI


var ai_brain


## 返回{COMMAND_TYPE, Value}
func get_command() -> Dictionary:
	if ai_brain:
		return ai_brain.decide_next_action()
	return {}
