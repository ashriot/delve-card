extends TextureButton
class_name Square

signal clicked

var type: String
var clicked: = false

func initialize(texture: Texture, _type: String) -> void:
	type = _type
	if texture == null:
		clicked = true
		modulate.a = 0
	else:
		clicked = false
		modulate.a = 1
		texture_normal = texture

func _on_Square_button_down():
	if clicked: return
	modulate.a = 0.66

func _on_Square_button_up():
	AudioController.click()
	clicked = true
	modulate.a = 0
	emit_signal("clicked")
