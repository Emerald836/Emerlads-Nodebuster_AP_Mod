class_name ArchipelagoConnectionPopup
extends PanelContainer

signal back

@onready var url = %URL

@onready var password = %Password

@onready var connectBTN = %TextButton

@onready var slotname = %Slotname

@onready var backBTN = %BackBtn

var archipelagoMain: Node


var mainMenu: Node


var _ap_client


var isConnected: bool = false


var connectionButton



func _ready():
	backBTN.pressed.connect(_on_back)
	var mod_node = get_node("/root/ModLoader/Emerald-Archipelago")
	archipelagoMain = mod_node
	connectionButton = get_node("MarginContainer/VBoxContainer/HBoxContainer/MarginContainer2/VBoxContainer2/TextButton")
	if connectionButton.pressed.is_connected(_on_connection_button_pressed) == false: connectionButton.pressed.connect(_on_connection_button_pressed)
	_ap_client = mod_node.get_child(0)
	_ap_client.packetConnected.connect(_connected_to_room)
	Saver.load_game()
	url.text = archipelagoMain.local_server
	slotname.text = archipelagoMain.local_name


func _connected_to_room() -> void:
	if mainMenu == null: return
	back.emit()
	mainMenu.new_game.emit()




func _on_connection_button_pressed() -> void:
	_ap_client.connectToServer(url.text,slotname.text,password.text)


func _on_back() -> void:
	back.emit()
