extends ColorRect
class_name BuffCard

func initialize(buff_name: String, desc: String) -> void:
	$Label.text = buff_name + "\n" + desc
	show()
