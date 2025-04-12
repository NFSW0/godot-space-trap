class_name BuffUnKnockBack
extends Buff


func start():
	print("add")


func end(_existing_buff_array:Array[Buff]):
	BuffManager.append_buff(buff_id, buff_target.get_path())
