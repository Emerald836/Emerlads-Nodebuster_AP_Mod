extends Control


signal hint_location_parsed(loc_name,level)


# Archipelago Client Variables
var apClient

var is_client_connected: bool = false ## Is this game client connected to an ap randomizer room


var local_server: String
var local_name: String


# APWorld Options
var milestones_in_itempool: bool = false
var crypto_levels_in_itempool: bool = false
var bossdrops_setting: int = 0
var goal: int = 0



const MOD_NAME = "Emerald-Archipelago"
const MOD_VERSION = "0.1.0"
const LOG_NAME = MOD_NAME + "/mod_main"


# Nodes
var archipelagoConsole: Control ## The modded console to connect to and display the apworld and the items sent and recieved.
var upgradeTree: UpgradeTree
var battleScene: BattleScene
var upgradeDescription: UpgradeDescription
var milestonePage: MilestonesPage
var shopScene: ShopScene

var progressiveItemStore: Node


# Crypto Mine Variables
var ap_mine_level: int = 0 ## Defines how many crypto mine levels have been recieved by the player.



# Milestone Variables
var new_milestone_data: Array[Milestone] = [ # Add an entry here for a new milestone. Milestones here won't show up in the milestone page.
	Milestone.new({
		"id": "Boss Drop",
		"name": "BOSS DROP",
		"unlock_desc": "defeat a new boss",
		"reward": ResourceType.resource_str(ResourceType.CORES, "1"),
	}),
	Milestone.new({
		"id": "Extra Bits",
		"name": "EXTRA BITS",
		"unlock_desc": "a small reward",
		"reward": ResourceType.resource_str(ResourceType.BITS, "5000"),
	}),
	Milestone.new({
		"id": "Extra Nodes",
		"name": "EXTRA NODES",
		"unlock_desc": "a small reward",
		"reward": ResourceType.resource_str(ResourceType.NODES, "500"),
	}),
]


# Upgrade Variables
var infinities: Array = []


# Check Variables
var scouted_locations: Dictionary = {}

var hinted_locations: Dictionary = {}


# Item Variables
var stored_items: Dictionary = {}

var collected_items: Dictionary = {}

var stored_loc_item_pairs: Array = []

const item_descriptions: Dictionary = {
	"Reds500":"+500 Bits",
	"Reds2k":"+3,000 Bits",
	"Reds4k":"+5,000 Bits",
	"Reds6k":"+8,000 Bits",
	"Reds8k":"+12,000 Bits",
	"Reds10k":"+16,000 Bits",
	"Reds15k":"+20,000 Bits",
	"Reds20k":"+30,000 Bits",
	"Reds30k":"+50,000 Bits",
	"Reds50k":"+100,000 Bits",
	"Reds100k":"+1,000,000 Bits",
	
	"Blues10":"+5 Nodes",
	"Blues100":"+100 Nodes",
	"Blues200":"+200 Nodes",
	"Blues300":"+300 Nodes",
	"Blues500":"+500 Nodes",
	"Blues800":"+800 Nodes",
	"Blues1.2k":"+1,200 Nodes",
	"Blues1.6k":"+1,600 Nodes",
	"Blues2k":"+2,000 Nodes",
	"Blues4k":"+4,000 Nodes",
	"Blues8k":"+8,000 Nodes",
	
	"Yellows5":"+1 Processor",
	"Yellows10":"+1 Processor",
	"Yellows15":"+1 Processor",
	
	"CryptoLevel":"Increases the CryptoMine Speed",
	
	"Extra Bits":"Have some extra Bits",
	"Extra Nodes":"Have some extra Nodes",
	
	"Boss Drop":"+1 Core",
	
	"Progressive Damage":"Increases your next Damage Upgrade",
	"Progressive Health":"Increases your next Health Upgrade",
	"Progressive Regen":"Increases your next Regen Upgrade",
	"Progressive SpawnRate":"Increases your next Spawn Rate Upgrade",
	"Progressive Armor":"Increases your next Armor Upgrade",
	"Progressive Infinity":"Increases your next Infinity Upgrade",
	"Progressive Milestone Reward":"Gives the reward of your next milestone"
}

# Battle Variables
var killed_last_boss: bool = false


func _init() -> void:
	ModLoaderMod.add_hook(_ap_on_boss_defeated,"res://Scripts/Battle/BattleScene.gd","_on_boss_defeated")

	ModLoaderMod.add_hook(_shop_scene_ready,"res://Scripts/Shop/ShopScene.gd","_ready")

	ModLoaderMod.add_hook(_upgrade_tree_ready,"res://Scripts/Shop/UpgradeTree.gd","_ready")
	ModLoaderMod.add_hook(_upgrade_node_bought,"res://Scripts/Shop/UpgradeTree.gd","_on_upgrade_clicked")
	ModLoaderMod.add_hook(_check_location_scout,"res://Scripts/Shop/UpgradeTree.gd","update_upgrade_visiblity")

	ModLoaderMod.add_hook(_ap_description_refresh_ui,"res://Scripts/UI/UpgradeDescription.gd","refresh_ui")

	ModLoaderMod.add_hook(_on_milestone_claimed,"res://Scripts/Shop/MilestonesPage.gd","_on_milestone_claimed")
	ModLoaderMod.add_hook(_load_milestone,"res://Scripts/Milestones/MilestoneEntry.gd","load_milestone")

	ModLoaderMod.add_hook(_calculate_speed,"res://Scripts/Systems/CryptoMine.gd","calculate_speed")
	ModLoaderMod.add_hook(_mine_level_up,"res://Scripts/Systems/CryptoMine.gd","level_up")

	ModLoaderMod.add_hook(_state_save,"res://Scripts/Autoloads/State.gd","save")
	ModLoaderMod.add_hook(_state_load,"res://Scripts/Autoloads/State.gd","load_save")
	ModLoaderMod.add_hook(_upgrade_load,"res://Scripts/Autoloads/Stores/UpgradeStore.gd","load_save")

	ModLoaderMod.add_hook(_start_game,"res://Scripts/MainScene.gd","_on_new_game")

func _ready():

	get_tree().node_added.connect(_node_added)
	get_tree().node_removed.connect(_node_removed)


	var apc = load("res://mods-unpacked/Emerald-Archipelago/ap/ArchipelagoClient.gd").new()
	call_deferred("add_child",apc)
	apClient = apc
	apc.item_received.connect(_recieved_item_from_server)
	apc.packetConnected.connect(_connected_to_room)
	apc.location_scout_retrieved.connect(_get_scout_data)
	apc.client_disconnected.connect(_apc_disconnected)
	apc.onDeathFound.connect(_death_found)
	apc.sync_retrieved.connect(_sync)
	apc.hint_retrieved.connect(_parse_hint)

	var pistore = load("res://mods-unpacked/Emerald-Archipelago/ProgressiveItemStore.gd").new()
	call_deferred("add_child",pistore)
	pistore.modMain = self
	progressiveItemStore = pistore

	_add_console_scene(self)
	
	ModLoaderLog.success("Archipelago mod v%s initialized" % MOD_VERSION, LOG_NAME)


func _node_added(node:Node) -> void:
	if node is UpgradeTree:
		upgradeTree = node
	elif node is BattleScene:
		battleScene = node
		node.ready.connect(_setup_battle_scene.bind(node))
	elif node is UpgradeDescription:
		upgradeDescription = node
	elif node is MilestonesPage:
		milestonePage = node
	elif node is Ending:
		node.ready.connect(_ending_ready.bind(node))
	elif node is ShopScene:
		shopScene = node
	
	elif node is MainMenu: # If we are in the main menu connect the ready to allow for custom setup.
		node.ready.connect(_main_menu_ready.bind(node))


func _node_removed(node:Node) -> void:
	if node is UpgradeTree:
		upgradeTree = null
	elif node is BattleScene:
		battleScene = null
	elif node is UpgradeDescription:
		upgradeDescription = null
	elif node is MilestonesPage:
		milestonePage = null


# Upgrade Tree Functions
func _shop_scene_ready(chain:ModLoaderHookChain) -> void:
	chain.execute_next()
	
	if is_client_connected:
		var upgrade_list_make = load("res://mods-unpacked/Emerald-Archipelago/Scenes/UpgradeListButton.tscn").instantiate()
		upgrade_list_make.position = Vector2(352,130)
		shopScene.call_deferred("add_child",upgrade_list_make)
		if stored_items.is_empty(): return
	Refs.curr_scn = shopScene
	var keysToRemove: Array = stored_items.keys()
	for item in stored_items:
		for i in stored_items[item]["count"]:
			var value = stored_items[item]["id"]
			_apply_item(item,value)
	for item in keysToRemove:
		stored_items.erase(item)


func _upgrade_tree_ready(chain: ModLoaderHookChain) -> void:
	chain.execute_next()
	var children: Array[Node] = upgradeTree.get_children()
	for child: Node in children:
		if child is UpgradeNode:
			if child.upgrade.is_maxed():
				continue
			var hint_make = load("res://mods-unpacked/Emerald-Archipelago/Scenes/HintIndicator.tscn").instantiate()
			hint_make.upgradeNode = child
			hint_make.location_name = child.upgrade_id
			if hinted_locations.has(child.upgrade_id):
				for level in hinted_locations[child.upgrade_id]:
					if child.upgrade.curr_level >= level:
						hinted_locations[child.upgrade_id].erase(level)
						continue
					hint_make._is_hint_location(child.upgrade_id,level)
			upgradeTree.call_deferred("add_child",hint_make)
			hint_make.global_position = child.global_position + Vector2(-2,-2)
			hint_location_parsed.connect(hint_make._is_hint_location)
			child.clicked.connect(hint_make._upgrade_node_clicked)



func _upgrade_node_bought(chain:ModLoaderHookChain, upgrade_node:UpgradeNode) -> void: # When the client buys an upgrade and is connected. will increase the upgrade nodes level without giving the upgrade.
	if is_client_connected == false:
		chain.execute_next([upgrade_node])
		return
	var upgrade: Upgrade = upgrade_node.upgrade
	if not upgrade.can_buy(): return
	var cost = upgrade.get_cost()
	State.lose_resource(upgrade.resource_type, cost)
	Refs.curr_scn.squash_resource(upgrade.resource_type)

	upgrade.curr_level += 1

	var locationName: String = str(upgrade_node.upgrade_id) + "-" + str(upgrade.curr_level)
	_send_check(locationName)

	Refs.upgrade_description.refresh_ui()
	Refs.upgrade_description.spring_level_up()
	upgrade_node.refresh_ui()
	upgrade_node.spring()
	
	upgradeTree.update_upgrade_visiblity(upgrade_node)
	for connected_node: UpgradeNode in upgrade_node.connected_nodes:
		upgradeTree.update_upgrade_visiblity(connected_node)


func _check_location_scout(chain: ModLoaderHookChain, upgrade_node: UpgradeNode) -> void: # Hooks Upgrade Tree Update Upgrade Visibilty Function.
	# Checks to see if newely shown upgrades were location scouted and if not then send scout.
	chain.execute_next([upgrade_node])
	if upgrade_node.visible == false: return

	var upgrade: Upgrade = upgrade_node.upgrade
	if scouted_locations.has(upgrade_node.upgrade_id + "-" + str(upgrade.curr_level)): return
	
	var upgrades_locations: PackedStringArray = []
	for i in upgrade.costs.size(): # Gets every location this upgrade node has.
		upgrades_locations.append(upgrade_node.upgrade_id + "-" + str(i+1))

	_send_location_scouts(upgrades_locations) # Send the list of locations


func _ap_description_refresh_ui(chain: ModLoaderHookChain) -> void: # When description refreshs ui. give custom name and description.
	if not upgradeDescription.upgrade: return
	var upgrade: Upgrade = upgradeDescription.upgrade

	var ap_item_name = str(upgrade.id + "-" + str(upgrade.curr_level + 1))

	var scouted_location = scouted_locations.get(ap_item_name,null)
	if scouted_location == null: # If we do not have the upgrade in out scouted_locations then do vanilla function.
		chain.execute_next()
		return
	
	var player_name: String = scouted_location["playerName"]
	var item_name: String = scouted_location["itemName"]

	var item_description: String = "{Item_Description}\n{Item_Name}"

	if player_name.contains("you"):
		player_name = player_name.insert(player_name.find("[/"),"r")
		player_name += " "
		
		var item = UpgradeStore.search(item_name)
		if item != null:
			item_description = item_description.format({"Item_Description":item.description})
		elif item_descriptions.has(item_name):
			item_description = item_description.format({"Item_Description":item_descriptions[item_name]})
	else:
		player_name = player_name + "'s "
		item_description = item_description.format({"Item_Description":"An Archipelago Item"})
	
	item_description = item_description.format({"Item_Name": ap_item_name})

	var item_to_give_name = player_name + item_name

	upgradeDescription.upgrade_name.text = item_to_give_name
	upgradeDescription.description.text = "[center]%s[/center]" % item_description
	upgradeDescription.level.text = "[center]Lv. %d / %d[/center]" % [upgradeDescription.upgrade.curr_level, upgradeDescription.upgrade.get_max_level()]
	
	upgradeDescription.update_cost_text()
	propagate_notification(NOTIFICATION_VISIBILITY_CHANGED)


# Milestone Page Functions
func _on_milestone_claimed(chain: ModLoaderHookChain, entry:MilestoneEntry) -> void:
	if is_client_connected == false:
		chain.execute_next([entry])
		return
	entry.set_claimed()
	_send_check(entry.milestone.id)
	milestonePage.update_notification_dot()


func _load_milestone(chain: ModLoaderHookChain,_milestone: Milestone) -> void:

	var ap_location_name = str(_milestone.id)
	

	var scouted_location = scouted_locations.get(ap_location_name,null)
	chain.execute_next([_milestone])
	if scouted_location == null: # If we do not have the upgrade in out scouted_locations then do vanilla function.
		
		return
	
	var player_name: String = scouted_location["playerName"]
	var item_name: String = scouted_location["itemName"]
	
	var item_description: String = "{Item_Description}\n{Location_Name}"

	if player_name.contains("you"):
		player_name = player_name.insert(player_name.find("[/"),"r")
		player_name += " "
		
		var item = MilestoneStore.search(item_name)
		if item != null:
			item_description = item_description.format({"Item_Description":item.unlock_desc})
	else:
		player_name = player_name + "'s "
		item_description = item_description.format({"Item_Description":"An Archipelago Item"})
	
	item_description = item_description.format({"Location_Name": ap_location_name})

	var item_to_give_name = player_name + item_name
	
	for milestone_entry in milestonePage.milestone_vbox.get_children():
		
		if milestone_entry is MilestoneEntry:
			if milestone_entry.milestone == _milestone:
				
				milestone_entry.milestone = _milestone
	
				var progress: float = clamp(Refs.upgrade_processor.check_milestone(milestone_entry.milestone), 0.0, 1.0)
				milestone_entry.claim_btn.set_enabled(progress >= 1.0)
				
				milestone_entry.icon.texture = milestone_entry.milestone.icon
				milestone_entry.milestone_name.text = milestone_entry.milestone.name
				milestone_entry.unlock_condition.text = "%s %s(%.1f%%)[/color]" % [milestone_entry.milestone.unlock_desc,
						Utils.hex(MyColors.GREEN), progress*100.0]
				milestone_entry.reward.text = Utils.colored("REWARD: " + item_to_give_name, MyColors.YELLOW)
				
				if milestone_entry.milestone.claimed:
					milestone_entry.set_claimed()
				
				return


# Crypto Mine Functions
func _calculate_speed(chain: ModLoaderHookChain) -> void:
	if crypto_levels_in_itempool == false:
		chain.execute_next()
		return
	match ap_mine_level:
		0: State.crypto_mine.curr_speed = 5
		1: State.crypto_mine.curr_speed = 10
		2: State.crypto_mine.curr_speed = 20
		3: State.crypto_mine.curr_speed = 40
		4: State.crypto_mine.curr_speed = 80
		5: State.crypto_mine.curr_speed = 160
		6: State.crypto_mine.curr_speed = 320
		7: State.crypto_mine.curr_speed = 640
		8: State.crypto_mine.curr_speed = 1280
		9: State.crypto_mine.curr_speed = 1800
		10: State.crypto_mine.curr_speed = 2600
		11: State.crypto_mine.curr_speed = 3400
		12: State.crypto_mine.curr_speed = 4200
		13: State.crypto_mine.curr_speed = 5200
		14: State.crypto_mine.curr_speed = 6400
		15: State.crypto_mine.curr_speed = 7600
		16: State.crypto_mine.curr_speed = 8800
		17: State.crypto_mine.curr_speed = 10000
		18: State.crypto_mine.curr_speed = 12000
		19: State.crypto_mine.curr_speed = 14000
		20: State.crypto_mine.curr_speed = 17000
		21: State.crypto_mine.curr_speed = 21000
		22: State.crypto_mine.curr_speed = 25000
		23: State.crypto_mine.curr_speed = 32000
		24: State.crypto_mine.curr_speed = 42000
		25: State.crypto_mine.curr_speed = 52000
		26: State.crypto_mine.curr_speed = 64000
		27: State.crypto_mine.curr_speed = 80000
		28: State.crypto_mine.curr_speed = 100000
		29: State.crypto_mine.curr_speed = 124000
		30: State.crypto_mine.curr_speed = 164000
		31: State.crypto_mine.curr_speed = 228000
		32: State.crypto_mine.curr_speed = 320000
		33: State.crypto_mine.curr_speed = 480000
		34: State.crypto_mine.curr_speed = 640000
		35: State.crypto_mine.curr_speed = 820000
		36: State.crypto_mine.curr_speed = 1280000
		_: State.crypto_mine.curr_speed  = 1280000


func _mine_level_up(chain: ModLoaderHookChain) -> void: # When client level ups CryptoMine if levels are in pool. send check.
	chain.execute_next()
	if is_client_connected == false or crypto_levels_in_itempool == false: return
	_send_check("CryptoLevel-"+str(State.crypto_mine.mine_level))


# AP Client Functions.
func _connected_to_room() -> void:
	is_client_connected = true

	var slot_data = apClient._slot_data

	goal = slot_data["goal"]

	milestones_in_itempool = false
	crypto_levels_in_itempool = false

	bossdrops_setting = slot_data["bossdrops"]

	# TODO: Currently this just adds every new milestone. not a problem but if I were to add more then im just adding unneeded data.
	if bossdrops_setting != 0: # If boss drops are in the pool. Add new milestones to milestone data.
		for new_milestone: Milestone in new_milestone_data:
			if MilestoneStore._data_dict.has(new_milestone.id) == true: continue
			MilestoneStore._data_dict[new_milestone.id] = new_milestone

	if apClient._slot_data["milestone"] == 1:
		milestones_in_itempool = true

		var milestone_names: PackedStringArray = [] # Scout for milestone info before the milestone entries get loaded. so even if you get milestones unlocked early they will still display proper rewards and names.
		for milestone in MilestoneStore.data:
			var milestone_id = milestone.id
			milestone_names.append(milestone_id)
		_send_location_scouts(milestone_names)
	
	if apClient._slot_data["crypto"] == 1:
		crypto_levels_in_itempool = true


func _apc_disconnected() -> void:
	is_client_connected = false


func _sync() -> void:
	stored_items.clear()
	collected_items.clear()
	progressiveItemStore.reset()

# Retrieve Information from Server
func _recieved_item_from_server(itemID) -> void:
	var itemName = apClient._getItemName(itemID)
	if SFX.sound_dict.has(21) == false:
		SFX.sound_dict[21] = load("res://Audio/SFX/Pickup.ogg")
		SFX.cooldown_dict[21] = 0
	SFX.play(21,0.05,5)
	stored_loc_item_pairs.append(itemID) # This array is never used again. TODO: Remove.
	if upgradeTree == null or is_instance_valid(upgradeTree) == false or is_instance_valid(Refs.curr_scn) == false: # If we are not in the upgrade tree scene or if the upgrade tree scene is not valid. send items to storage to be processed when we do get to the upgrade tree.
		if stored_items.has(itemName):
			stored_items[itemName]["count"] += 1
			return
		stored_items[itemName] = {"id":itemID,"count":1}
		return
	
	_apply_item(itemName,itemID)


func _get_scout_data(scout_data) -> void: # When scout data is retrieved parse it and store it.
	if scout_data.is_empty(): return
	for item in scout_data:
		var loc_data: Dictionary = {}
		loc_data["itemID"] = item.itemId
		loc_data["locationID"] = item.locationId
		loc_data["playerName"] = item.playerName
		loc_data["itemName"] = item.itemName
		var idx: String = apClient._location_id_to_name[item.locationId]
		scouted_locations[idx] = loc_data


func _parse_hint(hint_location:String) -> void:
	var split:PackedStringArray = hint_location.split("-") # Split the hint location to the upgrade node id and the level
	
	var loc_name:String = split[0]
	var loc_level: int = int(split[1])
	
	if hinted_locations.has(loc_name): # If we already parsed the location id then check to see if we have the level. and if we dont add it to the list.
		if hinted_locations[loc_name].has(loc_level): return
		hinted_locations[loc_name].append(loc_level)
	hinted_locations[loc_name] = [loc_level]
	hint_location_parsed.emit(loc_name,loc_level)
	SFX.play(6)


func _death_found() -> void: # If server sends death link death. Kill client if in battle scene.
	if battleScene == null: return
	if apClient._death_link == false: return
	battleScene.health_bar.die()

# Send Information to Server

func _check_goal() -> void:
	match goal:
		0: # Virus Deployed
			if State.virus_deployed:
				apClient.completedGoal()
		1: # Virus Deployed + Infinities
			if State.virus_deployed:
				for id in ["Infinity1","Infinity2","Infinity3","Infinity4","Infinity5","Infinity6","Infinity7","Infinity8","Infinity9"]:
					if infinities.has(id) == false: return
				apClient.completedGoal()


func _send_check(checkName:String) -> void: ## Send a location/check id to the archipelago server.
	if is_client_connected == false: return
	var checkID = apClient._location_name_to_id.get(checkName,null)
	if checkID == null: return
	apClient.sendLocation(checkID)


func _send_location_scouts(location_names: PackedStringArray = [], location_ids: PackedInt64Array = []) -> void: # Sends a list of location ids to the server to then send back scout data.
	var scoutData: PackedInt64Array = []

	if location_names.is_empty() == false:
		for loc_name in location_names:
			var loc_id = apClient._location_name_to_id.get(loc_name,null)
			if loc_id == null: continue
			scoutData.append(loc_id)
	
	if location_ids.is_empty() == false:
		for loc_id in location_ids:
			scoutData.append(loc_id)
	
	if scoutData.is_empty(): return
	apClient.sendScout(scoutData)


# Item Functions
func _apply_item(itemName,itemID) -> void: # Figures out what the item is and then applys it to the client.
	if collected_items.has(itemName):
		collected_items[itemName]["count"] += 1
	else:
		collected_items[itemName] = {"id":itemID,"count":1}
	# Check if Button Item
	match itemName:
		"CryptoMine":
			pass
		"Milestones":
			pass
		"Laboratory":
			pass
		"CryptoLevel":
			_ap_mine_level_up()
		"Prestige":
			pass
		"BossItem":
			pass
	
	
	# Check if Upgrade Item
	if UpgradeStore.search(itemName) != null:
		var upgrade = UpgradeStore.search(itemName)
		_ap_gain_upgrade(upgrade)
		Refs.upgrade_processor.gain_upgrade(upgrade, 0)
	# Check if Milestone Item
	elif MilestoneStore.search(itemName) != null:
		var milestone = MilestoneStore.search(itemName)
		if new_milestone_data.has(milestone): # If milestone is in the modded milestone data then use custom gain milestone function and return.
			_ap_gain_milestone(milestone)
			return
		Refs.upgrade_processor.gain_milestone(milestone)
	
	elif progressiveItemStore.search(itemName) != "":
		_apply_item(progressiveItemStore.search(itemName),null)
		progressiveItemStore.progressive_items[itemName] += 1



# Upgrade Functions
func _ap_gain_upgrade(upgrade:Upgrade): # If an upgrade has different behavior when randomized go here
	match upgrade.id: # TODO: Make sure that the button upgrades display button correctly
		"Milestones":
			State.stats.milestones_unlocked = true
			if is_instance_valid(Refs.curr_scn):
				if Refs.curr_scn is ShopScene:
					Refs.curr_scn.show_milestones_btn()
		"CryptoMine":
			State.stats.crypto_mine_unlocked = true
			if is_instance_valid(Refs.curr_scn):
				if Refs.curr_scn is ShopScene:
					Refs.curr_scn.show_crypto_mine_btn()
		"Infinity1":
			if infinities.has(upgrade.id) == false:
				infinities.append(upgrade.id)
		"Infinity2":
			if infinities.has(upgrade.id) == false:
				infinities.append(upgrade.id)
		"Infinity3":
			if infinities.has(upgrade.id) == false:
				infinities.append(upgrade.id)
		"Infinity4":
			if infinities.has(upgrade.id) == false:
				infinities.append(upgrade.id)
		"Infinity5":
			if infinities.has(upgrade.id) == false:
				infinities.append(upgrade.id)
		"Infinity6":
			if infinities.has(upgrade.id) == false:
				infinities.append(upgrade.id)
		"Infinity7":
			if infinities.has(upgrade.id) == false:
				infinities.append(upgrade.id)
		"Infinity8":
			if infinities.has(upgrade.id) == false:
				infinities.append(upgrade.id)
		"Infinity9":
			if infinities.has(upgrade.id) == false:
				infinities.append(upgrade.id)
		"Laboratory":
			State.stats.lab_unlocked = true
			if is_instance_valid(Refs.curr_scn):
				if Refs.curr_scn is ShopScene:
					Refs.curr_scn.show_lab_btn()



# Milestone Functions
func _ap_gain_milestone(milestone:Milestone) -> void:
	match milestone.id:
		"Boss Drop":
			State.cores += 1
		"Extra Bits":
			State.bits += 500
		"Extra Nodes":
			State.nodes += 500


# Cryptomine Functions
func _ap_mine_level_up() -> void:
	ap_mine_level += 1
	State.crypto_mine.calculate_speed()


# Prestige/Boss/Battle Functions



# Location/Check Functions
# Upgrade Functions


# Milestone Functions


# Cryptomine Functions


# Prestige/Boss/Battle Functions
func _ap_on_boss_defeated(chain: ModLoaderHookChain) -> void: # On boss defeat
	var ap_max_prestige: int = 25
	match bossdrops_setting:
		0: # No boss drops in pool so do default.
			chain.execute_next()
			return
	
	if killed_last_boss: # If you killed the last boss indicated by the ap_max_prestige var then give normal drops.
		chain.execute_next()
		return

	if not battleScene.battle_over:
		battleScene.battle_over = true
		if State.max_prestige == State.curr_prestige: # If we just beat the current max prestige send boss check.
			_send_check("Boss-" + str(State.max_prestige))
	
	battleScene.create_battle_end_screen(1)
	
	if State.max_prestige == State.curr_prestige:
		if State.max_prestige < 25:
				State.max_prestige += 1
				State.curr_prestige += 1
		else:
			killed_last_boss = true
		if State.max_prestige > ap_max_prestige:
			killed_last_boss = true


# Other Functions
func _add_console_scene(node:Node) -> void: ## Spawn console scene
	var console_scene = load("res://mods-unpacked/Emerald-Archipelago/ArchipelagoConsole.tscn").instantiate()
	console_scene.archipelagoMain = self
	node.call_deferred("add_child",console_scene)


func _ending_ready(endingScn: Ending) -> void: # When ending scene is ready. connect signals.
	endingScn.anim_player.animation_started.connect(_ending_animation_check)

func _ending_animation_check(_anim_name) -> void: # When ending animation is ran. check to see if goal was achieved.
	_check_goal()


func _main_menu_ready(main_menu:Node) -> void: # Spawn Archipelago Connect Button when Main menu is shown.
	var connection_button = load("res://mods-unpacked/Emerald-Archipelago/ArchipelagoMenuButton.tscn").instantiate()
	connection_button.main = self
	connection_button.mainMenu = main_menu
	var button_container = main_menu.get_node("UI/HBoxContainer")
	button_container.call_deferred("add_child",connection_button)
	button_container.get_child(0).call_deferred("queue_free")
	button_container.get_child(1).call_deferred("queue_free")


func _start_game(chain:ModLoaderHookChain) -> void:
	var start_game: bool = true
	if Saver.has_save() and local_server == apClient._ap_server:
		print("Has Save and last local server save is equal to this one")
		var confirmation: ConfirmationPopup = Refs._confirmation.instantiate()
		Refs.popups.add_popup(confirmation)
		await Defer.new_frame
		confirmation.setup("Your old save was already connected to this world. Start new game?", "no", "yes")
		Refs.popups.focus_curr()
		start_game = await confirmation.chosen
		Refs.popups.pop_curr()
	if start_game:
		Saver.create_new_save()
		Saver.save_game()
	Refs.main_scn.enter_shop()


# Saving and Loading Functions

# State Functions
func _state_save(chain: ModLoaderHookChain) -> Dictionary:
	var save: Dictionary = inst_to_dict(State)
	save.erase("@path")
	save.erase("@subpath")
	save["version"] = 0
	save["nums"] = State.nums.save()
	save["crypto_mine"] = State.crypto_mine.save()
	save["ap_info"] = {"address":apClient._ap_server,"slot_name":apClient._ap_user}
	save.erase("stats")
	
	return save


func _state_load(chain: ModLoaderHookChain,save: Dictionary) -> void:
	State.reset()
	var prop_list: Array = State.get_property_list()
	for property in prop_list:
		if save.has(property.name):
			set(property.name, save[property.name])
	State.nums = Numbers.new().load_save(save.nums)
	State.crypto_mine = CryptoMine.new().load_save(save.crypto_mine)
	if save.has("ap_info"):
		local_server = save.ap_info.address
		local_name = save.ap_info.slot_name

# Upgrade Functions
func _upgrade_load(chain: ModLoaderHookChain,save: Dictionary) -> void:
	UpgradeStore.reset()
	for upgrade_id: String in save:
		var upgrade: Upgrade = UpgradeStore.search(upgrade_id)
		if upgrade:
			upgrade.curr_level = clampi(save[upgrade_id], 0, upgrade.get_max_level())


# Battle Scene Functions
func _setup_battle_scene(battleScn: BattleScene) -> void: # When battle scene is ready. connect signals.
	battleScn.health_bar.health_zeroed.connect(_health_zeroed_in_fight)


func _health_zeroed_in_fight() -> void: # When you lost all health in battle scene. send death through death link if enabled.
	if is_client_connected == false: return
	if apClient._death_link == false: return
	apClient.sendDeath("Session Terminated.")
