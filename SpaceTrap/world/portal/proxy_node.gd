# 代理节点脚本
class_name ProxyNode
extends Node

# 原节点的引用
var original_node: Node = null

# 构造函数：初始化代理节点并绑定原节点
func _init(original: Node):
	if not original:
		print("错误：原节点不能为空！")
		return
	original_node = original

# 拦截属性读取
func _get(property: StringName) -> Variant:
	if original_node and original_node.has_method("_get"):
		return original_node._get(property)
	elif original_node.has_property(property):
		return original_node.get(property)
	else:
		print("警告：尝试读取不存在的属性 '%s'" % property)
		return null

# 拦截属性写入
func _set(property: StringName, value: Variant) -> bool:
	if original_node and original_node.has_method("_set"):
		return original_node._set(property, value)
	elif original_node.has_property(property):
		original_node.set(property, value)
		return true
	else:
		print("警告：尝试写入不存在的属性 '%s'" % property)
		return false

# 拦截方法调用
func _call(method: String, varargs: Array) -> Variant:
	if original_node and original_node.has_method(method):
		return original_node.callv(method, varargs)
	else:
		print("警告：尝试调用不存在的方法 '%s'" % method)
		return null
