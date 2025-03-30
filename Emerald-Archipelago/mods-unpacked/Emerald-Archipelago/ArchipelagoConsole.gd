extends CanvasLayer
class_name ArchipelagoConsole

@onready var console_toggle = $ArchipelagoConsole/VBoxContainer/ConsoleToggle
@onready var console_input = $ArchipelagoConsole/VBoxContainer/ScrollContainer/ConsoleInput
@onready var console_text = $ArchipelagoConsole/HBoxContainer/ConsoleText
@onready var scroll_container = $ArchipelagoConsole/VBoxContainer/ScrollContainer

@onready var url = $ArchipelagoConsole/HBoxContainer/URL
@onready var password = $ArchipelagoConsole/HBoxContainer/VBoxContainer/Password

@onready var connectBTN = $ArchipelagoConsole/HBoxContainer/VBoxContainer/TextButton

@onready var slotname = $ArchipelagoConsole/HBoxContainer/Slotname

var archipelagoMain: Node

var messages: PackedStringArray


var _ap_client: ArchipelagoClient

var isConnected: bool = false


func _ready():
	var mod_node = get_node("/root/ModLoader/Emerald-Archipelago")
	
	
	print(mod_node)
	_ap_client = mod_node.get_child(0)
	_ap_client.logInformations.connect(_new_message)
	_ap_client.packetConnected.connect(_connected_to_room)
	_ap_client.client_disconnected.connect(_disconnected_from_room)
	_ap_client.logInformations.connect(_log_informations)


func _log_informations(message:String) -> void:
	if message == "Disconnecting...":
		_disconnected_from_room()


func _process(delta):
	scroll_container.scroll_horizontal += 1


func _connected_to_room() -> void:
	url.visible = false
	slotname.visible = false
	password.visible = false
	isConnected = true
	connectBTN.btn_text = "Disconnect"
	connectBTN.main_color = Color(.94,.22,.24,1)


func _disconnected_from_room() -> void:
	url.visible = true
	slotname.visible = true
	password.visible = true
	isConnected = false
	connectBTN.btn_text = "Connect"
	connectBTN.main_color = Color(.27,.47,.96,1)


func _new_message(message:String) -> void:
	print("Message recieved: ", message)
	if message == "Disconnecting...":
		_disconnected_from_room()
	console_text.append_text("\n"+message)
	#archipelagoMain.console_history = console_text.text


func _check_cmd(message:String) -> void:
	if message.begins_with("archipelago.gg:"):
		try_connection(message)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		if url.visible:
			try_connection("")


func try_connection(message:String) -> void:
	print("try to connect")
	
	_ap_client.connectToServer(url.text,slotname.text,password.text)



func _on_console_input_text_submitted(new_text):
	
	_new_message(new_text)
	_check_cmd(new_text)
	console_input.clear()


func _on_console_toggle_toggled(toggled_on):
	console_input.visible = toggled_on
	console_text.visible = toggled_on


func _on_text_button_pressed():
	if isConnected == false:
		if url.text == "" and slotname.text == "": return
		try_connection("")
		return
	_ap_client.disconnect_from_ap()
