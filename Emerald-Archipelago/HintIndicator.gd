class_name HintIndicator
extends NinePatchRect


var location_name: String

var hint_levels: Array = []

var upgradeNode: UpgradeNode

func _upgrade_node_clicked() -> void:
	if upgradeNode.upgrade.is_maxed() or hint_levels.is_empty():
		visible = false
		return
	for level in hint_levels:
		if upgradeNode.upgrade.curr_level >= level:
			hint_levels.erase(level)
	
	if hint_levels.is_empty():
		visible = false
		return

func _is_hint_location(hint_loc_name: String,hintLevel: int) -> void:
	if upgradeNode.upgrade.is_maxed():
		visible = false
		return
	if hint_loc_name == location_name:
		visible = true
		hint_levels.append(hintLevel)
