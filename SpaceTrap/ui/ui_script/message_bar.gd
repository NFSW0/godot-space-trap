## 信息栏
## 包含历史信息栏和输入栏
extends Control
class_name MessageBar


## 发送信息
func send_message(message):
	var new_label = Label.new()
	new_label.name = %HistoryBar.get_child_count()
	new_label.text = message
	%HistoryBar.add_child(new_label)


## 编辑信息
func edit_message():
	%InputBar.show()
	%InputBar.grab_focus()


## 发送信息
func _on_input_bar_text_submitted(new_text: String) -> void:
	%InputBar.release_focus()
	%InputBar.hide()
	send_message(new_text)
