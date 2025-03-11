## 控制器基本类 用于获取行动指令
extends Resource
class_name ControllerBase


enum COMMAND_TYPE {
	MOVE_TOWARD, ## 定向移动 - Vec2 | Vec3
	MOVE_TO, ## 定点移动 - Vec2 | Vec3
	INTERACT, ## 互动 - Vec2 | Vec3
	ATTACK, ## 攻击 - Vec2 | Vec3
	DEFENSE, ## 防御 - Vec2 | Vec3
}


## 返回{COMMAND_TYPE, Value}
func get_command() -> Dictionary:
	return {}
