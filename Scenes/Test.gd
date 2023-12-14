extends Node2D
@export var packed_key : PackedScene

@onready var v_box_container = $VBoxContainer
@onready var h_box_container = $VBoxContainer/HBoxContainer
@onready var h_box_container_2 = $VBoxContainer/HBoxContainer2
@onready var h_box_container_3 = $VBoxContainer/HBoxContainer3

var key_numbers_per_row = [10, 9, 7]
var hbox_containers = []
var keys_to_handle = [
	KEY_Q, KEY_W, KEY_E, KEY_R, KEY_T, KEY_Y, KEY_U, KEY_I, KEY_O, KEY_P,
	KEY_A, KEY_S, KEY_D, KEY_F, KEY_G, KEY_H, KEY_J, KEY_K, KEY_L,
	KEY_Z, KEY_X, KEY_C, KEY_V, KEY_B, KEY_N, KEY_M
]

#var key_names = [
	#"81", "87", "69", "82", "84", "89", "85", "73", "79", "80",
	#"65", "83", "68", "70", "71", "72", "74", "75", "76",
	#"90", "88", "67", "86", "66", "78", "77"
#]

var key_names = [
	"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P",
	"A", "S", "D", "F", "G", "H", "J", "K", "L",
	"Z", "X", "C", "V", "B", "N", "M"
]
# Called when the node enters the scene tree for the first time.
func _ready():
	hbox_containers = [h_box_container, h_box_container_2, h_box_container_3]
	var key_index = 0
	for i in range(3):
		for key in range(key_numbers_per_row[i]):
			var button = packed_key.instantiate()
			button.name = key_names[key_index]
			button.text = key_names[key_index]
			hbox_containers[i].add_child(button)
			key_index += 1
		print("\nnew\n")

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode in keys_to_handle:
			handle_key_press(event.keycode)

func handle_key_press(key_press):
	var key = char(key_press)
	
	match key:
		"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P":
			var buttons = h_box_container.get_children()
			toggle_button(buttons, key)
		"A", "S", "D", "F", "G", "H", "J", "K", "L":
			var buttons = h_box_container_2.get_children()
			toggle_button(buttons, key)
		"Z", "X", "C", "V", "B", "N", "M":
			var buttons = h_box_container_3.get_children()
			toggle_button(buttons, key)

func toggle_button(buttons, key):
	for button in buttons:
		if button.name == key:
			button.disabled = !button.disabled
			
	
	
