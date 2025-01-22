## 目标行为 作为行为树中的叶子节点 是一个可能发生的行为逻辑
extends BehaviorBase
class_name BehaviorTask


var action: Callable = Callable()


func execute() -> int:
	if action:
		return action.call()
	return Status.FAILURE
