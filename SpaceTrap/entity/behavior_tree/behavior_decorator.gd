## 装饰行为 条件判断成功后执行后续行为 应仅有一个子节点
## 可依据数据拓展多种装饰器用于条件判断 比如生命值条件、类型条件、距离条件、坐标条件等
extends BehaviorBase
class_name BehaviorDecorator


class BehaviorCondition:
	var condition_type
	var condition_value


var condition: Callable = Callable() ## 判断条件


## 如果条件判定成功则执行子节点
func execute() -> int:
	for child in get_children():
		if condition and not condition.call():
			return Status.FAILURE
		return child.execute()
	return Status.FAILURE
