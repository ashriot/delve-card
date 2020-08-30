extends ColorRect
class_name Card

onready var animation_player = $AnimationPlayer

var ap_cost: int
var mp_cost: int
var damage: int
var hits: int

var action_button
var initialized = false

func initialize(_action_button) -> void:
	action_button = _action_button
	$Panel/AP.hide()
	$Panel/MP.hide()
	$Panel/Sprite.frame = action_button.action.frame_id
	$Panel/Title.text = action_button.action.name
	var description = action_button.action.description
	$Panel/Type.text = description[0]
	$Panel/Description.text = description[1]
	var rarity: String
	for _i in range(action_button.action.rarity):
		rarity += "*"
	$Panel/Rarity.text = rarity
	if action_button.action.drop:
		$Drop.show()
	else:
		$Drop.hide()
	if action_button.action.consume:
		$Consume.show()
	else:
		$Consume.hide()
	ap_cost = action_button.action.ap_cost
	mp_cost = action_button.action.mp_cost
	damage = action_button.action.damage
	hits = action_button.action.hits
	update_data()
	modulate.a = 0
	var pos = Vector2(0, get_global_mouse_position().y - $Panel.rect_size.y - 10)
	$Panel.rect_global_position = pos
	pos = Vector2(pos.x, pos.y - 17)
	$Drop.rect_global_position = pos
	$Consume.rect_global_position = pos
	show()
	animation_player.play("FadeIn")
	initialized = true

func update_data() -> void:
	if action_button.action.ap_cost > 0:
		$Panel/AP.rect_size = Vector2(5 * action_button.action.ap_cost, 7)
		$Panel/AP.show()
	elif action_button.action.mp_cost > 0:
		$Panel/MP.bbcode_text = " " + str(action_button.action.mp_cost) + "MP"
		$Panel/MP.show()
	
	var hit_text = "" if hits < 2 else ("x" + str(hits))
	var type = "HP" if action_button.action.healing else "dmg"
	if action_button.action.damage_type == action_button.action.DamageType.AC:
		type = "AC"
	elif action_button.action.damage_type == action_button.action.DamageType.MP:
		type = "MP"
	elif action_button.action.damage_type == action_button.action.DamageType.AP:
		type = "AP"
	var prepend = "+" if action_button.action.healing else ""
	var text = "[right]" + prepend + str(damage) + hit_text + type
	if action_button.action.damage == 0:
		text = ""
	$Panel/Damage.bbcode_text = text

func close() -> void:
	animation_player.play("FadeOut")
	yield(animation_player, "animation_finished")
	hide()
