extends CanvasLayer

#@onready var console_toggle = $ArchipelagoConsole/VBoxContainer/ConsoleToggle
#@onready var console_input = $ArchipelagoConsole/VBoxContainer/ScrollContainer/ConsoleInput
@onready var console_text = $ArchipelagoConsole/HBoxContainer/ConsoleText

@onready var url = $ArchipelagoConsole/HBoxContainer/URL
@onready var password = $ArchipelagoConsole/HBoxContainer/VBoxContainer/Password

@onready var connectBTN = $ArchipelagoConsole/HBoxContainer/VBoxContainer/TextButton

@onready var slotname = $ArchipelagoConsole/HBoxContainer/Slotname

var archipelagoMain: Node

var messages: PackedStringArray


var _ap_client

var isConnected: bool = false


var connectionButton

func _ready():
	var mod_node = get_node("/root/ModLoader/Emerald-Archipelago")
	connectionButton = get_node("ArchipelagoConsole/HBoxContainer/VBoxContainer/TextButton")
	connectionButton.main_color = Color.GREEN
	if ModLoaderMod.is_mod_loaded("Emerald-Archipelago"):
		connectionButton.main_color = Color.RED
	if connectionButton.pressed.is_connected(_on_text_button_pressed) == false: connectionButton.pressed.connect(_on_text_button_pressed)
	_ap_client = mod_node.get_child(0)
	_ap_client.logInformations.connect(_new_message)
	_ap_client.packetConnected.connect(_connected_to_room)
	_ap_client.client_disconnected.connect(_disconnected_from_room)
	_ap_client.logInformations.connect(_log_informations)


func _log_informations(message:String) -> void:
	if message == "Disconnecting...":
		_disconnected_from_room()




func _connected_to_room() -> void:
#	pass
	url.visible = false
	slotname.visible = false
	password.visible = false
	isConnected = true
	#connectBTN.btn_text = "Disconnect"
	#connectBTN.main_color = Color(.94,.22,.24,1)


func _disconnected_from_room() -> void:
#	pass
	#url.visible = true
	#slotname.visible = true
	#password.visible = true
	isConnected = false
	#connectBTN.btn_text = "Connect"
	#connectBTN.main_color = Color(.27,.47,.96,1)


func _new_message(message:String) -> void:
	#print("Message recieved: ", message)
	if message == "Disconnecting...":
		_disconnected_from_room()
	console_text.append_text("\n"+message)
	#archipelagoMain.console_history = console_text.text


func _check_cmd(message:String) -> void:
	if message.begins_with("archipelago.gg:"):
		try_connection(message)



func try_connection(_message:String) -> void:
#	print("try to connect")
	return
	#_ap_client.connectToServer(url.text,slotname.text,password.text)




func _on_text_button_pressed():
	if isConnected == false:
		if url.text == "" and slotname.text == "": return
		try_connection("")
		return
	_ap_client.disconnect_from_ap()
