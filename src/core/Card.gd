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
	if _action_button is TrinketButton:
		init_trinket(_action_button.trinket)
		return
	action_button = _action_button
	action = action_button.action as Action
	var potion = true if \
		action.action_type == Action.ActionType.ITEM \
		else false
	$Panel/AP.hide()
	$Panel/MP.hide()
	$Panel/Info/Dodge.hide()
	$Panel/Info/Hide.hide()
	$Panel/Info/Lifesteal.hide()
	$Panel/Info/Weak.hide()
	$Panel/Info/Poison.hide()
	$Panel/Info/Blind.hide()

	if potion: $Panel/Sprite.frame = 60
	else: $Panel/Sprite.frame = action.frame_id
	$Panel/Title.text = action.name
	var description = action.description
	$Panel/Type.text = description[0]
	$Panel/Description.text = description[1]
	var rarity:= ""
	for _i in range(action.rarity): rarity += "*"
	$Panel/Rarity.text = rarity
	if action.drop: $Panel/Info/Drop.show()
	else: $Panel/Info/Drop.hide()
	if action.fade: $Panel/Info/Fade.show()
	else: $Panel/Info/Fade.hide()
	if action.consume: $Panel/Info/Consume.show()
	else: $Panel/Info/Consume.hide()
	if action.penetrate: $Panel/Info/Penetrate.show()
	else: $Panel/Info/Penetrate.hide()
	if action.impact > 0:
		$Panel/Info/Impact.show()
		var text = "Impact x%imp [color=#88cac7b8]Gain %impx damage bonus from Power."
		text = text.replace("%imp", str(action.impact))
		$Panel/Info/Impact/Label.bbcode_text = text
	else: $Panel/Info/Impact.hide()

	# BUFFS
	if action.gain_buffs.size() > 0:
		for item in action.gain_buffs:
			var buff = item[0] as Buff
			if buff.name == "Dodge": $Panel/Info/Dodge.show()
			elif buff.name == "Hide": $Panel/Info/Hide.show()
			elif buff.name == "Lifesteal": $Panel/Info/Lifesteal.show()

	# DEBUFFS
	if action.inflict_debuffs.size() > 0:
		for item in action.inflict_debuffs:
			var debuff = item[0] as Buff
			if debuff.name == "Weak": $Panel/Info/Weak.show()
			elif debuff.name == "Poison": $Panel/Info/Poison.show()
			elif debuff.name == "Blind": $Panel/Info/Blind.show()

	if !potion:
		if have > 0:
			$Panel/Have.text = "Have: " + str(have)
		else:
			if !action.action_type == Action.ActionType.INJURY:
				$Panel/Have.text = "New!"
			else:
				$Panel/Have.text = ""
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
	show()
	set_pos()
	animation_player.play("FadeIn")
	initialized = true

func init_trinket(trinket: Trinket) -> void:
	$Panel/MP.hide()
	$Panel/AP.hide()
	$Panel/Damage.hide()
	var rank = ""
	if trinket.rank > 0: rank = "+" + str(trinket.rank)
	$Panel/Title.text = trinket.name + rank
	$Panel/Sprite.frame = 63
	var description = trinket.description
	$Panel/Type.text = description[0]
	$Panel/Description.text = description[1]
	var rarity:= ""
	for _i in range(trinket.rarity):
		rarity += "*"
	$Panel/Rarity.text = rarity

	$Panel/Info/Drop.hide()
	$Panel/Info/Fade.hide()
	$Panel/Info/Consume.hide()
	$Panel/Info/Penetrate.hide()
	$Panel/Info/Impact.hide()

	modulate.a = 0
	show()
	set_pos()
	animation_player.play("FadeIn")
	initialized = true

func get_pos() -> Vector2:
	var y = max(13, get_global_mouse_position().y - $Panel.rect_size.y - 10)
	if y == 13:
		y = get_global_mouse_position().y + 15
	y += - 18 if (action.drop or action.consume or action.penetrate
		or action.impact) else 0
	var pos = Vector2(0, y)
	return pos

func update_data() -> void:
	if action.cost_type == Action.DamageType.AP and action.cost > 0:
		$Panel/AP.rect_size = Vector2(5 * ap_cost, 7)
		$Panel/AP.show()
	elif action.cost_type == Action.DamageType.MP and action.cost > 0:
		$Panel/MP.bbcode_text = " " + str(mp_cost) + "MP"
		$Panel/MP.show()
	elif action.cost_type == Action.DamageType.HP and action.cost > 0:
		$Panel/MP.bbcode_text = " -" + str(hp_cost) + "HP"
		$Panel/MP.show()

	var hit_text = "" if hits < 2 else ("x" + str(hits))
	if action.name == "Lightning Claws": hit_text += "x?"
	var prepend = "-"
	if action.damage_type == Action.DamageType.HP: prepend = ""
	var type = "dmg"
	if action.healing:
		type = "HP"
		prepend = "+"
	if action.damage_type == Action.DamageType.AC:
		type = "AC"
	elif action.damage_type == Action.DamageType.MP:
		type = "MP"
	elif action.damage_type == Action.DamageType.AP:
		type = "ST"
	var drown = "+"
	if action.name != "Drown":
		drown = ""
	var text = "[right]" + prepend + str(damage) + drown + hit_text + type
	if action.damage == 0:
		text = ""
	if action.name == "Brilliant Crystal":
		text = "[right]+2xMP"
	if action.name == "Armor Up":
		text = "[right]+2xAC"
	if action.name == "Shield Slam":
		text = "[right][AC] dmg"
	$Panel/Damage.bbcode_text = text

func close() -> void:
	if visible:
		animation_player.play("FadeOut")
		yield(animation_player, "animation_finished")
		hide()
	else: hide()

func set_pos() -> void:
	var pos = get_global_mouse_position() as Vector2
	if pos.y < ($Panel.rect_size.y + 10):
		$Panel.rect_position.y = pos.y + 15
	else:
		$Panel.rect_position.y = 4


func _on_Button_button_down():
	close()
