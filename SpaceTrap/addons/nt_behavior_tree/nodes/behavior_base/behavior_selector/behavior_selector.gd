## 选择行为 依次执行其子节点的行为 子节点全失败则返回失败
extends BehaviorBase
class_name BehaviorSelector


func execute(delta: float, entity: ControllableEntity2D) -> int:
	for child in get_children():
		var result = child.execute(delta, entity)
		match result:
			Status.SUCCESS:
				return Status.SUCCESS
			Status.RUNNING:
				return Status.RUNNING
	return Status.FAILURE
