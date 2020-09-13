extends ColorRect
class_name Card

onready var animation_player = $AnimationPlayer

var ap_cost: int
var mp_cost: int
var hp_cost: int
var damage: int
var hits: int

var action_button
var action
var initialized = false

func initialize(_action_button, have: int) -> void:
	action_button = _action_button
	action = action_button.action
	var potion = true if \
		action.action_type == Action.ActionType.ITEM \
		else false
	$Panel/AP.hide()
	$Panel/MP.hide()
	if potion:
		$Panel/Sprite.frame = 60
	else:
		$Panel/Sprite.frame = action.frame_id
	$Panel/Title.text = action.name
	var description = action.description
	$Panel/Type.text = description[0]
	$Panel/Description.text = description[1]
	var rarity: String
	for _i in range(action.rarity):
		rarity += "*"
	$Panel/Rarity.text = rarity
	if action.drop:
		$Drop.show()
	else:
		$Drop.hide()
	if action.fade:
		$Fade.show()
	else:
		$Fade.hide()
	if action.consume:
		$Consume.show()
	else:
		$Consume.hide()
	if !potion:
		if have > 0:
			$Panel/Have.text = "Have: " + str(have)
		else:
			$Panel/Have.text = "New!"
		if action.cost_type == Action.DamageType.AP:
			ap_cost = action.cost
		elif action.cost_type == Action.DamageType.MP:
			mp_cost = action.cost
		elif action.cost_type == Action.DamageType.HP:
			hp_cost = action.cost
		damage = action.damage
		hits = action.hits
		$Panel/Damage.show()
		update_data()
	else:
		$Panel/Have.text = ""
		$Panel/Damage.hide()
	modulate.a = 0
	var pos = get_pos()
	$Panel.rect_global_position = pos
	pos = Vector2(pos.x, pos.y + $Panel.rect_size.y - 1)
	$Drop.rect_global_position = pos
	$Consume.rect_global_position = pos
	show()
	animation_player.play("FadeIn")
	initialized = true

func get_pos() -> Vector2:
	var y = max(13, get_global_mouse_position().y - $Panel.rect_size.y - 10 \
	- (18 if action.consume else 0))
	if y == 13:
		y = get_global_mouse_position().y + 15
	var pos = Vector2(0, y)
	return pos

func update_data() -> void:
	if action.cost_type == Action.DamageType.AP and action.cost > 0:
		$Panel/AP.rect_size = Vector2(6 * ap_cost, 7)
		$Panel/AP.show()
	elif action.cost_type == Action.DamageType.MP and action.cost > 0:
		$Panel/MP.bbcode_text = " " + str(mp_cost) + "MP"
		$Panel/MP.show()
	elif action.cost_type == Action.DamageType.HP and action.cost > 0:
		$Panel/MP.bbcode_text = " -" + str(hp_cost) + "HP"
		$Panel/MP.show()
	
	var hit_text = "" if hits < 2 else ("x" + str(hits))
	var type = "HP" if action.healing else "dmg"
	if action.damage_type == Action.DamageType.AC:
		type = "AC"
	elif action.damage_type == Action.DamageType.MP:
		type = "MP"
	elif action.damage_type == Action.DamageType.AP:
		type = "ST"
	var prepend = "+" if action.healing else ""
	var drown = "+"
	if action.name != "Drown":
		drown = ""
	var text = "[right]" + prepend + str(damage) + drown + hit_text + type
	if action.damage == 0:
		text = ""
	if action.name == "Brilliant Crystal":
		text = "[right]+2xMP"
	$Panel/Damage.bbcode_text = text

func close() -> void:
	if visible:
		animation_player.play("FadeOut")
		yield(animation_player, "animation_finished")
		hide()
