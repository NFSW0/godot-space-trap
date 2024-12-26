## 可序列化的数据类(子类必须重写序列化方法和实例化方法)
extends Resource
class_name SerializableData


## 序列化方法(子类必须重写)
func serialize():
	assert(false, "You must override the 'serialize' method in the subclass!")


## 实例化方法(子类必须重写)
static func instantiate(data = null):
	assert(false, "You must override the 'instantiate' method in the subclass!")
