class_name ProgressiveItemStore
extends Node

var modMain: Node


const data: Dictionary = {
	"Progressive Damage": {"Damage1":{"start":0,"count":15},"DamagePerEnemy1":{"start":15,"count":5},"BossDamage1":{"start":20,"count":10},"Damage2":{"start":30,"count":10},"Damage3":{"start":40,"count":10},
	"Undamaged1":{"start":50,"count":6},"Execute1":{"start":56,"count":6},"Damage4":{"start":62,"count":3},"BossDamage2":{"start":65,"count":10},"CritDamage1":{"start":75,"count":10},
	"Damage5":{"start":85,"count":5},"Undamaged2":{"start":90,"count":4},"Execute2":{"start":94,"count":4},"RampingDamage1":{"start":98,"count":3},"CritDamage2":{"start":101,"count":8},"MaxHealthToDamage1":{"start":109,"count":1}},
	
	"Progressive Health": {"Health1":{"start":0,"count":10},"Health2":{"start":10,"count":8},"Health3":{"start":18,"count":10},"Health4":{"start":28,"count":10},"Health5":{"start":38,"count":3},
	"Health6":{"start":41,"count":5},"Health7":{"start":46,"count":5}},
	
	"Progressive Regen": {"HealthRegen1":{"start":0,"count":5},"Salvaging1":{"start":5,"count":5},"Lifesteal1":{"start":10,"count":5},"HealthRegen2":{"start":15,"count":1},"Salvaging2":{"start":16,"count":1},
	"DropHeal1":{"start":17,"count":1},"MaxHealthHeal1":{"start":18,"count":10},"Lifesteal2":{"start":28,"count":3},"Lifesteal3":{"start":31,"count":2},"StealMaxHealth1":{"start":33,"count":1},
	"MaxHealthHeal2":{"start":34,"count":5},"StealMaxHealth2":{"start":39,"count":1},"StealMaxHealth3":{"start":40,"count":1}},
	
	"Progressive SpawnRate": {"SpawnRate1":{"start":0,"count":15},"NodeFinder1":{"start":15,"count":5},"SpawnRate2":{"start":20,"count":1},"SpawnRate3":{"start":21,"count":5},"YellowSpawn1":{"start":26,"count":1},
	"SpawnRate4":{"start":27,"count":5},"YellowSpawn2":{"start":32,"count":1}},
	
	"Progressive Armor": {"Armor1":{"start":0,"count":10},"BossArmor1":{"start":10,"count":10},"Armor2":{"start":20,"count":5},"ArmorPerEnemy1":{"start":25,"count":10},"Armor3":{"start":35,"count":10},
	"Armor4":{"start":45,"count":10},"BossArmor2":{"start":55,"count":8},"Armor5":{"start":63,"count":20},"Armor6":{"start":83,"count":30},"MaxHealthToArmor1":{"start":113,"count":5},"Armor7":{"start":118,"count":5},
	"FocusArmor1":{"start":123,"count":5},"MaxHealthToArmor2":{"start":128,"count":1},"RampingArmor1":{"start":129,"count":5}},
	
	"Progressive Infinity": {"Infinity1":{"start":0,"count":1},"Infinity2":{"start":1,"count":1},"Infinity3":{"start":2,"count":1},"Infinity4":{"start":3,"count":1},
	"Infinity5":{"start":4,"count":1},"Infinity6":{"start":5,"count":1},"Infinity7":{"start":6,"count":1},"Infinity8":{"start":7,"count":1},"Infinity9":{"start":8,"count":1},},
	
	"Progressive Milestone Reward": {"Reds500":{"start":0,"count":1},"Blues10":{"start":1,"count":1},"Reds2k":{"start" :2,"count":1},"Blues100":{"start" :3,"count":1},"Reds4k":{"start": 4,"count":1},"Blues200":{"start": 5,"count":1},
	"Reds6k":{"start": 6,"count":1},"Blues300":{"start": 7,"count":1},"Reds8k":{"start": 8,"count":1},"Blues500":{"start": 9,"count":1},"Reds10k":{"start": 10,"count":1},
	"Blues800":{"start": 11,"count":1},"Yellows5":{"start": 12,"count":1},"Reds15k":{"start": 13,"count":1},"Blues1.2k":{"start": 14,"count":1},"Yellows10":{"start": 15,"count":1},
	"Reds20k":{"start": 16,"count":1},"Blues1.6k":{"start": 17,"count":1},"Yellows15":{"start": 18,"count":1},"Reds30k":{"start": 19,"count":1},"Blues2k":{"start": 20,"count":1},
	"Reds50k":{"start": 21,"count":1},"Blues4k":{"start": 22,"count":1},"Reds100k":{"start": 23,"count":1},"Blues8k":{"start": 24,"count":1}}
}

var progressive_items: Dictionary = {
	"Progressive Damage": 0,
	"Progressive Health": 0,
	"Progressive Regen": 0,
	"Progressive SpawnRate": 0,
	"Progressive Armor": 0,
	"Progressive Infinity": 0,
	"Progressive Milestone Reward": 0
}


func search(itemName) -> String:
	var group = data[itemName]
	for item_name in group.keys():
		var value = group[item_name]
		if progressive_items[itemName] >= value["start"] and progressive_items[itemName] < value["start"] + value["count"]:
			return item_name
	
	return ""


func reset() -> void:
	for group in progressive_items.keys():
		progressive_items[group] = 0
