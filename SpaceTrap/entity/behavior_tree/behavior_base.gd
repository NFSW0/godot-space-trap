## 基础行为 通常仅用于继承 无任何直接作用
extends Node
class_name BehaviorBase


## 状态(进行中， 成功 - 结束本次行为决策， 失败 - 在行为树中继续寻找下一个合理的行为)
enum Status { RUNNING, SUCCESS, FAILURE }


## 行动
func execute() -> int:
	return Status.SUCCESS
