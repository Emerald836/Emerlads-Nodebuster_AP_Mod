class_name ArchipelagoMenuButton
extends Control


const CONNECTION_POPUP = preload("res://mods-unpacked/Emerald-Archipelago/ArchipelagoConnectionPopup.tscn")
var mod_button

var main: Node

var mainMenu: Node

func _ready():
	mod_button = get_child(0)
	if mod_button.pressed.is_connected(_on_options_pressed) == false: mod_button.pressed.connect(_on_options_pressed)
	get_parent().move_child(self,0)



func _on_options_pressed() -> void:
	var modOptionScene = CONNECTION_POPUP.instantiate()
	#modOptionScene.main = main
	modOptionScene.mainMenu = mainMenu
	Refs.popups.add_popup(modOptionScene)
	Refs.popups.focus_curr()
