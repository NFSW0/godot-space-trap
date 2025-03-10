## 鼠动画(一维变量):静默(Idle)、移动(Move)、吃(Eat)、受伤(Hurt)、死亡(Dead)
extends InfluenceableEntity2D
#class_name Mouse


@export var animation_tree: AnimationTree ## 动画节点


## 过度到另一个动画 传入动画名称
func travel_animation(animation_name: String):
	if animation_tree:
		animation_tree.get("parameters/playback").travel(animation_name)
