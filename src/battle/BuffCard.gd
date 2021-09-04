extends ColorRect
class_name BuffCard

onready var anim = $AnimationPlayer
onready var label = $Label

func initialize(buff) -> void:
	label.text = buff.buff_name + "\n" + buff.description
	set_pos()
	modulate.a = 0
	show()
	anim.play("FadeIn")

func init_intent(intent: Action) -> void:
	label.text = intent.name + "\n" + intent.description[0] + ". " + \
		intent.description[1] + ". " + get_cost(intent)
	modulate.a = 0
	show()
	set_pos()
	anim.play("FadeIn")

func init_info(enemy: EnemyActor) -> void:
	label.text = enemy.get_desc()
	modulate.a = 0
	show()
	set_pos()
	anim.play("FadeIn")

func _on_Button_button_up() -> void:
	print("emergency hide!")
	fade_out()

func fade_out() -> void:
	anim.play("FadeOut")
	yield(anim, "animation_finished")
	hide()

func get_cost(intent: Action) -> String:
	if intent.cost < 1: return ""
	elif intent.cost_type == Action.DamageType.AP: return str(intent.cost) + " ST."
	elif intent.cost_type == Action.DamageType.HP: return str(intent.cost) + " HP."
	elif intent.cost_type == Action.DamageType.AC: return str(intent.cost) + " AC."
	else: return str(intent.cost) + " MP."

func set_pos() -> void:
	var pos = get_global_mouse_position() as Vector2
	if pos.y < (label.rect_size.y + 10):
		label.rect_position.y = pos.y + 15
	else:
		label.rect_position.y = 8
