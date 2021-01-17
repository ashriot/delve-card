extends Button
class_name PerkButton

onready var chosen: = false setget set_chosen

var perk: Perk
var desc: String setget , get_desc
var ranks: String setget, get_ranks

func initialize(_perk: Perk):
	perk = _perk
	$Chosen.hide()
	text = perk.name
	$Ranks.text = self.ranks
	$Chosen/Label.text = perk.name
	$Chosen/Ranks.text = self.ranks

func rank_up() -> void:
	perk.cur_ranks += 1
	$Ranks.text = self.ranks
	$Chosen/Ranks.text = self.ranks

func set_chosen(value) -> void:
	chosen = value
	if chosen:
		$Chosen.show()
	else:
		$Chosen.hide()

func get_desc() -> String:
	var text = perk.desc + "\n"
	if perk.trait:
		if perk.cur_ranks == 0:
			text += "\nTeaches: " + perk.name
		else:
			text += "\nLearned: " + perk.name
	else:
		if perk.cur_ranks > 0:
			text += "\nCurrent: "
			for i in range(perk.units.size()):
				text += "+" + str(perk.amts[i] * perk.cur_ranks) + " " + perk.units[i]
				text += "\n"
		else: text += "\n"
		if perk.cur_ranks < perk.max_ranks:
			text += "Next: "
			for i in range(perk.units.size()):
				text += "+" + str(perk.amts[i] * (perk.cur_ranks + 1)) + " " + perk.units[i]
				text += "\n"
	return text

func get_ranks() -> String:
	return str(perk.cur_ranks) + "/" + str(perk.max_ranks)
