extends "res://Scripts/Shop/UpgradeTree.gd"


var isUpgradeTree: bool
var upgradeTree: UpgradeTree
var milestonePage: MilestonesPage

var apClient: ArchipelagoClient

var upgrades: Dictionary

const MOD_NAME = "Emerald-Archipelago"
const MOD_VERSION = "0.5.1"
const LOG_NAME = MOD_NAME + "/mod_main"

var itemReceivedList: Array
var console: Control


var main_scene: MainScene


var milestoneUnlocked: bool = false
var cryptoUnlocked: bool = false
var labUnlocked: bool = false

var isConnected: bool = false

const ArchipelagoClient = preload("res://mods-unpacked/Emerald-Archipelago/ap/ArchipelagoClient.gd")



var firstUpgradeTreeViewing: bool = false # Remove This

var upgradeDesc: UpgradeDescription


var scout_data: Dictionary


func _init() -> void:
	
	ModLoaderMod.add_hook(_upgrade_tree_ready,"res://Scripts/Shop/UpgradeTree.gd","_ready")
	ModLoaderMod.add_hook(_override_upgrade_visibility,"res://Scripts/Shop/UpgradeTree.gd","update_upgrade_visiblity")
	ModLoaderMod.add_hook(_on_override_upgrade_clicked,"res://Scripts/Shop/UpgradeTree.gd","_on_upgrade_clicked")
	ModLoaderMod.add_hook(_on_override_milestone_claimed,"res://Scripts/Shop/MilestonesPage.gd","_on_milestone_claimed")
	ModLoaderMod.add_hook(_description_hook,"res://Scripts/UI/UpgradeDescription.gd","refresh_ui")
	ModLoaderMod.add_hook(gain_upgrade,"res://Scripts/Upgrades/UpgradeProcessor.gd","gain_upgrade")


func gain_upgrade(chain: ModLoaderHookChain, upgrade: Upgrade, level: int):
	match upgrade.id:
		"Damage1":
			State.stats.damage += 1
		"Size1":
			State.stats.player_size_mod += 0.1
		"Health1":
			State.stats.max_health += 4
		"SpawnRate1":
			State.stats.spawn_rate_mod += 0.5
		"Armor1":
			State.stats.armor += 0.2
		"BitBoost1":
			State.stats.bit_boost += 1
		"BossArmor1":
			State.stats.boss_armor += 1
		"HealthRegen1":
			State.stats.health_regen += 0.1
		"NodeFinder1":
			State.stats.blue_enemy_chance += 0.01
		"Salvaging1":
			State.stats.health_on_kill += 1
		"DamagePerEnemy1":
			State.stats.damage_mod_per_enemy += 0.05
		"BossDamage1":
			State.stats.boss_damage_mod += 0.5
		"AttackSpeed1":
			State.stats.attack_speed_mod += 0.2
		"BonusDropChance1":
			State.stats.bonus_drop_chance += 0.1
		"ExplodersChance":
			State.stats.exploder_spawn_chance += 0.05
		"Health2":
			State.stats.max_health += 12
		"Armor2":
			State.stats.armor += 0.6
		"Lifesteal1":
			State.stats.health_on_hit += 0.5
		"Damage2":
			State.stats.damage += 3
		"PickupRadius1":
			State.stats.drop_pickup_radius += 8
		"HealthRegen2":
			State.stats.health_regen += 4
		"Milestones":
			State.stats.milestones_unlocked = true
			milestoneUnlocked = true
			#if Refs.curr_scn is ShopScene:
			#	Refs.curr_scn.show_milestones_btn()
			MySteam.set_achievement("MILESTONES")
		"Salvaging2":
			State.stats.health_on_kill += 8
		"AttackSpeed2":
			State.stats.attack_speed_mod += 0.2
		"SpawnRate2":
			State.stats.spawn_rate_mod += 2.5
		"NodeBoost1":
			State.stats.node_boost += 1
		"ArmorPerEnemy1":
			State.stats.armor_mod_per_enemy += 0.02
		"Armor3":
			State.stats.armor += 2
		"DropHeal1":
			State.stats.health_on_pickup_drop += 0.5
		"Health3":
			State.stats.max_health += 80
		"PulseBolts":
			State.stats.pulse_bolt_count += 3
		"PulseBoltDamage1":
			State.stats.pulse_bolt_damage_mod += 0.25
		"PulseBoltCount1":
			State.stats.pulse_bolt_count += 1
		"ExplodersSize":
			State.stats.exploder_size += 0.15
		"MaxHealthHeal1":
			State.stats.max_health_regen += 0.01
		"Armor4":
			State.stats.armor += 5
		"BossArmor2":
			State.stats.boss_armor_mod += 0.25
		"Damage3":
			State.stats.damage += 6
		"Undamaged1":
			State.stats.undamaged_mod += 0.25
		"Execute1":
			State.stats.execute_mod += 0.25
		"CritChance1":
			State.stats.crit_chance += 0.1
		"SpawnRate3":
			State.stats.spawn_rate_mod += 1.0
		"Armor5":
			State.stats.armor += 2
		"Damage4":
			State.stats.damage += 25
		"Size2":
			State.stats.player_size_mod += 0.5
		"CryptoMine":
			State.stats.crypto_mine_unlocked = true
			cryptoUnlocked = true
			#if Refs.curr_scn is ShopScene:
			#	Refs.curr_scn.show_crypto_mine_btn()
			MySteam.set_achievement("CRYPTO_MINE")
		"YellowSpawn1":
			State.stats.yellow_enemy_chance += 0.001
		"Health4":
			State.stats.max_health += 300
		"Armor6":
			State.stats.armor += 5
		"BossDamage2":
			State.stats.boss_damage_mod += 1.0
		"Lifesteal2":
			State.stats.health_on_hit += 10
		"MovingPulser1":
			State.stats.auto_pulser_count += 1
		"Size3":
			State.stats.player_size += 1.0
		"MovingPulserSize1":
			State.stats.auto_pulser_size_mod += 0.25
		"MovingPulserAttackSpeed1":
			State.stats.auto_pulser_attack_speed_mod += 0.2
		"Health5":
			State.stats.max_health += 4000
		"Lifesteal3":
			State.stats.max_health_on_hit += 0.01
		"MaxHealthToArmor1":
			State.stats.max_health_armor += 0.01
		"CritDamage1":
			State.stats.crit_damage += 0.5
		"Damage5":
			State.stats.damage += 100
		"Armor7":
			State.stats.armor += 200
		"FocusArmor1":
			State.stats.focus_armor_mod += 0.5
		"StealMaxHealth1":
			State.stats.perma_max_health_on_kill += 1
		"PulseBoltExplode":
			State.stats.pulse_bolt_explode = true
		"MovingPulserSize2":
			State.stats.auto_pulser_size_mod += 0.5
		"PulseBoltCount2":
			State.stats.pulse_bolt_count += 2
		"PulseBoltDamage2":
			State.stats.pulse_bolt_damage_mod += 1.0
		"MovingPulserSpeed1":
			State.stats.auto_pulser_speed_mod += 0.2
		"Undamaged2":
			State.stats.undamaged_mod += 1.0
		"Execute2":
			State.stats.execute_mod += 1.0
		"MaxHealthHeal2":
			State.stats.max_health_regen += 0.02
		"RampingDamage1":
			State.stats.damage_mod_per_sec += 0.01
		"EnemyDeathPulseBolts":
			State.stats.enemy_death_pulse_bolt_chance += 0.01
		"SpawnRate4":
			State.stats.spawn_rate_mod += 4.0
		"StealMaxHealth2":
			State.stats.perma_max_health_on_kill += 2
		"MaxHealthToArmor2":
			State.stats.max_health_armor += 0.05
		"RampingArmor1":
			State.stats.armor_mod_per_sec += 0.01
		"Health6":
			State.stats.max_health += 50000
		"StealMaxHealth3":
			State.stats.perma_max_health_on_kill += 5
		"LightningChance1":
			State.stats.lightning_chance += 0.05
		"LightningChainCount1":
			State.stats.lightning_chains += 1
		"LightningDamage1":
			State.stats.lightning_damage_mod += 0.5
		"CritDamage2":
			State.stats.crit_damage += 2.0
		"MaxHealthToDamage1":
			State.stats.max_health_damage += 0.001
		"Health7":
			State.stats.max_health += 100000
		"Infinity1":
			State.stats.spawn_rate_mod += 10.0
			State.stats.perma_max_health_on_kill += 12
		"Laboratory":
			State.stats.lab_unlocked = true
			labUnlocked = true
			#if Refs.curr_scn is ShopScene:
			#	Refs.curr_scn.show_lab_btn()
			MySteam.set_achievement("THE_LAB")
		"YellowSpawn2":
			State.stats.yellow_enemy_chance += 0.004
		"AutoCollect":
			State.stats.autocollect_chance += 0.1


func _ready():
	
	get_tree().node_added.connect(_node_added)
	get_tree().node_removed.connect(_node_removed)
	
	
	# Make and connect archipelago client
	var apc = ArchipelagoClient.new()
	call_deferred("add_child",apc)
	apClient = apc
	apc.item_received.connect(_recieve_check)
	apc.packetConnected.connect(_connected_to_room)
	apc.location_scout_retrieved.connect(_get_scout_data)
	apc.client_disconnected.connect(_apc_disconnected)
	apc.onDeathFound.connect(_death_found)
	
	# Add the console scene
	_add_console_scene(self)
	
	ModLoaderLog.success("Archipelago mod v%s initialized" % MOD_VERSION, LOG_NAME)


var scouted_locations: Dictionary
var goal: int = 0

func _apc_disconnected() -> void:
	isConnected = false

func _get_scout_data(scout_data) -> void:
	if scout_data.is_empty(): return
	var newScoutData: Array
	for item in scout_data:
		newScoutData.append(item.itemName)
		var loc_data: Dictionary
		loc_data["itemID"] = item.itemId
		loc_data["locationID"] = item.locationId
		loc_data["playerName"] = item.playerName
		loc_data["itemName"] = item.itemName
		var idx: String = apClient._location_id_to_name[item.locationId]
		scouted_locations[idx] = loc_data
	#print("Scout Data: ",newScoutData)


func _connected_to_room() -> void: ## When the client is connected to room
	print("is connected")
	firstUpgradeTreeViewing = true
	isConnected = true
	#if is_instance_valid(Refs.curr_scn) == false:
		#Refs.curr_scn == self
	goal = apClient._slot_data["goal"]
	if upgradeTree:
		upgradeTree._ready()

func _add_console_scene(node:Node) -> void: ## Spawn console scene
	var console_scene = load("res://mods-unpacked/Emerald-Archipelago/ArchipelagoConsole.tscn").instantiate()
	node.call_deferred("add_child",console_scene)
	console_scene.archipelagoMain = self


func _node_added(node:Node) -> void:
	if node is MainScene:
		main_scene = node
		apClient.connected.connect(main_scene._on_new_game)
	if node is UpgradeTree:
		isUpgradeTree = true
		upgradeTree = node
	if node is MilestonesPage:
		milestonePage = node
	if node is UpgradeDescription:
		upgradeDesc = node
	if node is Ending:
		node.ready.connect(_ending_ready.bind(node))
		#node.anim_player.animation_started.connect(_ending_animation_check)
	if node is BattleScene:
		node.ready.connect(_setup_battle_scene.bind(node))


func _setup_battle_scene(battleScn:BattleScene) -> void:
	battleScn.health_bar.health_zeroed.connect(_health_zeroed_in_fight)
	battleScn.tree_exited.connect(_left_battle_scene)
	battleScene = battleScn

func _left_battle_scene() -> void:
	battleScene = null


var battleScene: BattleScene

func _death_found() -> void:
	if battleScene == null: return
	battleScene.health_bar.die()


func _ending_ready(endingScn: Ending) -> void:
	endingScn.anim_player.animation_started.connect(_ending_animation_check)

func _ending_animation_check(anim_name) -> void:
	_check_goal("virus")


func _health_zeroed_in_fight() -> void:
	if isConnected == false: return
	if apClient._death_link == false: return
	apClient.sendDeath("Lost all Health.")


func _send_item_id(id: String) -> void:
	if isConnected == false: return
	apClient.completedGoal()


func _node_removed(node:Node) -> void:
	if node is UpgradeTree:
		isUpgradeTree = false
		upgradeTree = null
	if node is MilestonesPage:
		milestonePage = null
	if node is UpgradeDescription:
		upgradeDesc = null

func _check_goal(msg:String) -> void:
	match goal:
		0: # Virus Deployed
			if State.virus_deployed:
				apClient.completedGoal()
		1:
			pass
		2:
			pass
		3:
			pass

func _reset_stats() -> void:
	State.stats = Stats.new()
	_give_items()


func _give_items() -> void:
	for item in storeUpgrades:
		_check_recieved_item(item)


var loc_ids: Array

func _upgrade_tree_ready(chain: ModLoaderHookChain) -> void: ## Upgrade tree ready. After we get the upgrade nodes we are gonna want to look through the checked locations and set the upgrade nodes current level
	if isUpgradeTree == false: return
	upgrades.clear()
	print("is ready")
	var children: Array[Node] = upgradeTree.get_children()
	for child: Node in children:
		if child is UpgradeNode:
			upgrades[child.name] = child
			for connected_node: UpgradeNode in child.connected_nodes:
				upgradeTree.create_connection(child, connected_node)
				# Make sure all nodes are connected both ways
				if not connected_node.connected_nodes.has(child):
					connected_node.connected_nodes.append(child)
			
			if child.hovered.is_connected(_on_hover_upgrade) == false: child.hovered.connect(_on_hover_upgrade.bind(child))
			if child.unhovered.is_connected(_on_unhover_upgrade) == false: child.unhovered.connect(_on_unhover_upgrade)
			if child.clicked.is_connected(_on_upgrade_clicked) == false: child.clicked.connect(_on_upgrade_clicked.bind(child))
	# Set visibility after all of the upgrade nodes connectinos were set.
	if apClient and isConnected:
		_get_loc_ids()
	
	
	
	
	
	for child: Node in children:
		if child is UpgradeNode:
			upgradeTree.update_upgrade_visiblity(child)
	if apClient == null or isConnected == false: return
	if firstUpgradeTreeViewing:
		local_locations_checked = _checked_loc_ids_to_name(loc_ids)
	firstUpgradeTreeViewing = false
	_reset_stats()

#	if State.stats.crypto_mine_unlocked == true:
#			print("Crypto Mine is unlocked")
	#		if is_instance_valid(Refs.curr_scn):
	#			Refs.curr_scn.show_crypto_mine_btn()
	#	if State.stats.lab_unlocked == true:
	#		if is_instance_valid(Refs.curr_scn):
	#			Refs.curr_scn.show_lab_btn()




func _get_loc_ids() -> void:
	loc_ids.clear()
	for upgrade_id in UpgradeStore._data_dict.keys():
		var upgrade = UpgradeStore._data_dict[upgrade_id]
		if upgrade.curr_level >= 0 and upgrade.curr_level < upgrade.costs.size():
			loc_ids.append(apClient._location_name_to_id[upgrade_id + "-" + str(upgrade.curr_level+1)])
	
	apClient.sendScout(loc_ids,2)


func _on_milestone_rewarded(entry:MilestoneEntry) -> void: ## Gives the reward of the milestone if you gain a milestone
	Refs.upgrade_processor.gain_milestone(entry.milestone)


func _on_override_milestone_claimed(chain:ModLoaderHookChain, entry:MilestoneEntry) -> void: ## Sets the milestone entry to claimed and sends check event
	entry.set_claimed()
	print("Milestone reached: ",entry)
	# Remove the gain milestone so you dont recieve the rewards for claiming a milestone
	#Refs.upgrade_processor.gain_milestone(entry.milestone)
	_send_check(entry)
	milestonePage.update_notification_dot()


func _description_hook(chain: ModLoaderHookChain) -> void:
	if not upgradeDesc.upgrade: return
	var item_to_give_name: String
	var item_desc: String = "An Archipelago Item"
	var apItemName = str(upgradeDesc.upgrade.id) + "-" + str(upgradeDesc.upgrade.curr_level+1)
	if scouted_locations.has(apItemName):
		var item = scouted_locations[apItemName]
		var playerName:String = item["playerName"]
		#print(playerName)
		if playerName.contains("you"):
			playerName = playerName.insert(playerName.find("[/"),"r")
			playerName += " "
		else:
			playerName = playerName + "'s "
		var itemName = item["itemName"]
		item_to_give_name = playerName + itemName
	else:
		item_to_give_name = upgradeDesc.upgrade.name
	
	upgradeDesc.upgrade_name.text = item_to_give_name
	upgradeDesc.description.text = "[center]%s[/center]" % item_desc
	upgradeDesc.level.text = "[center]Lv. %d / %d[/center]" % [upgradeDesc.upgrade.curr_level, upgradeDesc.upgrade.get_max_level()]
	
	upgradeDesc.update_cost_text()
	propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)


func _on_override_upgrade_clicked(chain:ModLoaderHookChain, upgrade_node:UpgradeNode) -> void:
	var upgrade: Upgrade = upgrade_node.upgrade
	if not upgrade.can_buy(): return
	var cost = upgrade.get_cost()
	State.lose_resource(upgrade.resource_type, cost)
	Refs.curr_scn.squash_resource(upgrade.resource_type)
	
	upgrade.curr_level += 1
	#UpgradeStore._data_dict[upgrade.id].curr_level += 1
	while local_locations_checked.count(upgrade.id) < upgrade.curr_level:
		local_locations_checked.append(upgrade.id) # Somethig with this causes lab to crash
	
	# Remove gain upgrade so the player dosent get stats.
	#Refs.upgrade_processor.gain_upgrade(upgrade, upgrade.curr_level)
	
	_send_check(upgrade_node)
	
	#_get_loc_ids()
	
	Refs.upgrade_description.refresh_ui()
	Refs.upgrade_description.spring_level_up()
	upgrade_node.refresh_ui()
	upgrade_node.spring()
	
	update_upgrade_visiblity(upgrade_node)
	for connected_node: UpgradeNode in upgrade_node.connected_nodes:
		update_upgrade_visiblity(connected_node)

func _send_check_id(id:String) -> void:
	if isConnected == false: return
	apClient.sendLocation(apClient._location_name_to_id[id])

func _send_check(node:Node) -> void: ## When you get something from Nodebreaker. send it to the server
	if isConnected == false: return
	if node is UpgradeNode:
		apClient.sendLocation(apClient._location_name_to_id[(str(node.upgrade.id) + "-" + str(node.upgrade.curr_level))])
		pass
	if node is MilestoneEntry:
		pass

var storeUpgrades: PackedInt64Array

func _recieve_check(itemID) -> void: ## When the server recieves a nodebreaker item. recieve it here
	#var itemName = apClient._getItemName(itemID)
	storeUpgrades.append(itemID)
	_reset_stats()
	if is_instance_valid(Refs.curr_scn) == false: return
	if Refs.curr_scn != UpgradeTree: return
	_check_recieved_item(itemID)

func _check_recieved_item(itemID) -> void: ## Checks through all of the upgrades and if the upgrades id matches the item. Give the upgrade.
	var itemName = apClient._getItemName(itemID)
	for key in upgrades.keys():
		var value = upgrades[key]
		if value.upgrade.id != itemName:
			continue
		Refs.upgrade_processor.gain_upgrade(value.upgrade,value.upgrade.curr_level)
		print("Unlocked Item: ", itemName)
		return
	print("There is no upgrade with that itemID") # If not in upgrades check milestones.

func _input(event) -> void:
	if isUpgradeTree == false: return
	if event.is_action_pressed("up"):
		_override_upgrade_clicked(upgrades["18"])


var local_locations_checked: Array = []


func _get_checked_locataions() -> Dictionary:
	var upgrade_name_and_count: Dictionary = {}
	for id in apClient._checked_locations:
		var location_name: String = apClient._location_id_to_name[id]
		var split = location_name.split("-",true,1)
		if upgrade_name_and_count.has(split[0]):
			upgrade_name_and_count[split[0]] += 1
			continue
		upgrade_name_and_count[split[0]] = 0
	return upgrade_name_and_count


func _checked_loc_ids_to_name(locIds) -> Array:
	var returnArray: Array
	for id in locIds:
		if apClient._location_id_to_name.has(id) == false: continue
		var locName: String = apClient._location_id_to_name[id]
		var split = locName.split("-")
		if split.is_empty() == false:
			returnArray.append(split[0])
	#print(returnArray)
	return returnArray


func _set_upgrade_nodes_levels():
	if apClient == null or isConnected == false: return
	var children: Array[Node] = upgradeTree.get_children()
	var checkedLocs = apClient._checked_locations
	for child: Node in children:
		if child is UpgradeNode:
			var localCount = local_locations_checked.count(child.upgrade_id)
			var apCount = _checked_loc_ids_to_name(checkedLocs).count(child.upgrade_id)
		#	print("Local Count: ",localCount)
		#	print("AP Count: ",apCount)
		#	print(child.upgrade_id,"AP Count: ",apCount,"Local Count: ",localCount)
			if localCount > apCount:
				if localCount > UpgradeStore._data_dict[child.upgrade_id].curr_level:
					child.upgrade.curr_level = localCount
					UpgradeStore._data_dict[child.upgrade_id].curr_level = localCount
			else:
				child.upgrade.curr_level = apCount
				UpgradeStore._data_dict[child.upgrade_id].curr_level = apCount

func _override_upgrade_visibility(chain: ModLoaderHookChain, upgrade_node: UpgradeNode) -> void:
	if isUpgradeTree == false: return
	#if chain != null and firstUpgradeTreeViewing:
		#var val = chain.execute_next([upgrade_node])
	if apClient and isConnected:
		_set_upgrade_nodes_levels()
	
	#if apClient._client != null:
		#var _checked_locations: Dictionary = _get_checked_locataions()
		#if _checked_locations.has(upgrade_node.upgrade.id):
		#	if local_locations_checked.has(upgrade_node.upgrade.id):
		#		if _checked_locations[upgrade_node.upgrade.id] <= local_locations_checked[upgrade_node.upgrade.id]:
		#			upgrade_node.upgrade.curr_level = local_locations_checked[upgrade_node.upgrade.id]
		#		else:
		#			upgrade_node.upgrade.curr_level = _checked_locations[upgrade_node.upgrade.id]
		#	else:
		#		upgrade_node.upgrade.curr_level = _checked_locations[upgrade_node.upgrade.id]
		#elif local_locations_checked.has(upgrade_node.upgrade.id):
		#	upgrade_node.upgrade.curr_level = local_locations_checked[upgrade_node.upgrade.id]
		#if _checked_locations.has(upgrade_node.upgrade.id) or local_locations_checked.has(upgrade_node.upgrade.id):
			#upgrade_node.upgrade.curr_level = _checked_locations[upgrade_node.upgrade.id]
	
	
	
	upgrade_node.visible = Refs.upgrade_processor.check_upgrade_unlocked(upgrade_node)
	if upgrade_node.upgrade.curr_level > 0:
		upgrade_node.visible = true
	if upgrade_node.upgrade.curr_level == 0:
		upgrade_node.modulate = lerp(Color.WHITE, MyColors.BG, 0.5)
	else:
		upgrade_node.modulate = Color.WHITE
	
	# Update tree's rect
	if upgrade_node.visible:
		upgradeTree.top_left.x = min(upgradeTree.top_left.x, upgrade_node.position.x)
		upgradeTree.top_left.y = min(upgradeTree.top_left.y, upgrade_node.position.y)
		upgradeTree.bot_right.x = max(upgradeTree.bot_right.x, upgrade_node.position.x+upgrade_node.size.x)
		upgradeTree.bot_right.y = max(upgradeTree.bot_right.y, upgrade_node.position.y+upgrade_node.size.y)
	
	# Node isn't visible: hide all connections
	if not upgrade_node.visible:
		for connected_node: UpgradeNode in upgrade_node.connect_lines:
			upgrade_node.connect_lines[connected_node].hide()
	# Node is visible: show all connections to other visible nodes
	else:
		for connected_node: UpgradeNode in upgrade_node.connect_lines:
			if connected_node.visible:
				upgrade_node.connect_lines[connected_node].show()
	if apClient and isConnected:
		_get_loc_ids()

func _find_unlocked_sequenced_broken_upgrades() -> void:
	if isUpgradeTree == false: return
	var children: Array[Node] = upgradeTree.get_children()
	for child: Node in children:
		if child is UpgradeNode:
			#upgradeTree._override_upgrade_visibility(child)
			upgradeTree.update_upgrade_visiblity(child)

func _override_upgrade_clicked(upgrade_node: UpgradeNode) -> void:
	if isUpgradeTree == false: return
	var upgrade: Upgrade = upgrade_node.upgrade
	#if upgrade.is_maxed(): return
	# Remove gaining a level so when you get an item it dosen't count as buying the upgrade
	#upgrade.curr_level += 1
	Refs.upgrade_processor.gain_upgrade(upgrade, upgrade.curr_level)
	
	Refs.upgrade_description.refresh_ui()
	Refs.upgrade_description.spring_level_up()
	upgrade_node.refresh_ui()
	upgrade_node.spring()
	
	
	#_override_upgrade_visibility(null, upgrade_node)
	for connected_node: UpgradeNode in upgrade_node.connected_nodes:
		upgradeTree.update_upgrade_visiblity(connected_node)
	
	upgradeTree.refresh_all_nodes()
