## 控制器基本类 用于获取行动指令
extends Resource
class_name ControllerBase


enum COMMAND_TYPE {
	MOVE_TOWARD, ## 定向移动 - Vec2 | Vec3
	MOVE_TO, ## 定点移动 - Vec2 | Vec3
	INTERACT, ## 是否互动 - Bool
	ATTACK, ## 是否攻击 - Bool
	DEFENSE, ## 是否防御 - Bool
}


## 返回{COMMAND_TYPE, Value}
func get_command() -> Dictionary:
	return {}
