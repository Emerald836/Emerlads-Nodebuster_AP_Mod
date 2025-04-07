extends Control


const POPUP = preload("res://mods-unpacked/Emerald-Archipelago/Scenes/UnlocksPopup.tscn")
var mod_button

var main: Node

var mainMenu: Node

func _ready():
	mod_button = get_child(0)
	if mod_button.pressed.is_connected(_on_options_pressed) == false: mod_button.pressed.connect(_on_options_pressed)



func _on_options_pressed() -> void:
	var modOptionScene = POPUP.instantiate()
	Refs.popups.add_popup(modOptionScene)
	Refs.popups.focus_curr()
