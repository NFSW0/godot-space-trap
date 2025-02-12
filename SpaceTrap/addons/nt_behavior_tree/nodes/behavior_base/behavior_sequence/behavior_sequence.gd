## 有序行为 依次执行其子节点的行为 是一个分支节点 不可作为叶子节点
extends BehaviorBase
class_name BahaviorSequence


func execute(delta: float, entity: ControllableEntity2D) -> int:
	for child in get_children():
		var result = child.execute(delta, entity)
		if result != Status.SUCCESS:
			return result
	return Status.SUCCESS
