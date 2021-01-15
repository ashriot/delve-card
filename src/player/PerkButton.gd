extends Button
class_name PerkButton


func initialize(perk: Perk):
	text = perk.name
	$Ranks.text = str(perk.cur_ranks) + "/" + str(perk.max_ranks)
