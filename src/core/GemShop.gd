extends BaseControl

onready var donor = $BG/DonorBundles
signal buy_gems(qty)

var gem_qty: String setget set_gem_qty

func _ready():
	var buttons = get_tree().get_nodes_in_group("GemButtons")
	for btn in buttons:
		btn.connect("pressed", self, "_on_GemButton_pressed", [btn])
	hide()

func _on_CloseShop_pressed():
	$BG/CloseShop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	self.hide()
	yield(self, "done")
	$BG/CloseShop.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_Donor_pressed():
	$BG/Donor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.click()
	donor.show()
	yield(donor, "done")
	$BG/Donor.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_DonorBack_pressed():
	$BG/DonorBundles/DonorBack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	AudioController.back()
	donor.hide()
	yield(donor, "done")
	$BG/DonorBundles/DonorBack.mouse_filter = Control.MOUSE_FILTER_STOP

func _on_GemButton_pressed(btn):
	AudioController.confirm()
	if btn.name == "Pile": emit_signal("buy_gems", 100)
	if btn.name == "Bounty": emit_signal("buy_gems", 2400)

func set_gem_qty(value) -> void:
	$BG/GemQty.text = str(value)
