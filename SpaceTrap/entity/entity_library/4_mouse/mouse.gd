## 鼠动画(一维变量):静默(Idle)、移动(Move)、吃(Eat)、受伤(Hurt)、死亡(Dead)
extends InfluenceableEntity2D
#class_name Mouse


@export var animation_tree: AnimationTree ## 动画节点


#region 动画
## 过度到另一个动画 传入动画名称
func travel_animation(animation_name: String, reset_on_teleport: bool = true):
	if animation_tree:
		animation_tree.set("parameters/%s/blend_position" % animation_name, velocity.normalized())
		animation_tree.get("parameters/playback").travel(animation_name, reset_on_teleport)
#endregion 动画
