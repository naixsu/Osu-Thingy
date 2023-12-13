extends Node
class_name Main

@export var Note : PackedScene

@export var beatmaps : Array[Resource]

@onready var noteGroup = $NoteGroup
@onready var audio : AudioStreamPlayer2D = $Audio

var path = "D:\\osu!\\Songs"
var OGPlayArea : Vector2 = Vector2(512, 384)
var offset : Vector2 = Vector2(408, 196)
var songLength : float = 0
var metadata : Dictionary = {
	"General" : {},
	"Metadata": {},
	"Difficulty": {},
	"HitObjects": [],
}



# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	var mp3 : AudioStream = beatmaps[i].mp3
	var beatmap = beatmaps[i].beatmap
	read_osu_file(beatmap)
	
	#print(metadata["Difficulty"])
	
	set_audio_stream(mp3)
	songLength = set_song_length()
	
	
	place_obects(metadata["HitObjects"])


## Set the AudioStreamPlayer's stream
func set_audio_stream(mp3: AudioStream) -> void:
	audio.set_stream(mp3)

## Set the song length in s to ms
func set_song_length() -> int:
	var length: float = audio.stream.get_length()
	var ms: int = length * 1000
	return ms

## Read a .txt file that was converted to an .osu file and parse it
func read_osu_file(beatmap: String) -> void:
	var file = FileAccess.open(beatmap, FileAccess.READ)
	var text = file.get_as_text()
	var current_metadata : String = ""
	
	while not file.eof_reached():
		var line = file.get_line()

		if "[General]" in line:
			current_metadata = line
		if "[Metadata]" in line:
			current_metadata = line
		if "[Difficulty]" in line:
			current_metadata = line
		if "[HitObjects]" in line:
			current_metadata = line
		
		match current_metadata:
			"[General]":
				var key_value = line.split(':')
				if len(key_value) == 2:
					metadata["General"][key_value[0]] = key_value[1]
			"[Metadata]":
				var key_value = line.split(':')
				if len(key_value) == 2:
					metadata["Metadata"][key_value[0]] = key_value[1]
			"[Difficulty]":
				var key_value = line.split(':')
				if len(key_value) == 2:
					metadata["Difficulty"][key_value[0]] = key_value[1]
			"[HitObjects]":
				var raw_data = line.split(',')
				if len(raw_data) >= 4:
					var data = {
							'x'     : raw_data[0],
							'y'     : raw_data[1],
							'time'  : raw_data[2],
							'type'  : raw_data[3],
						}
					metadata["HitObjects"].append(data)
	file.close()

## Places objects in the play area (scaled)
func place_obects(hitObjects: Array) -> void:
	for obj in hitObjects:
		var x = obj["x"].to_int()
		var y = obj["y"].to_int()
		var time = obj["time"].to_int()
		var type = obj["type"].to_int()
		var scaled_xy = get_scale_coords(x, y)
		
		var note = Note.instantiate()
		noteGroup.add_child(note)
		note.global_position = scaled_xy
		
		var circleSize = float(metadata["Difficulty"]["CircleSize"])
		note.scale = Vector2(circleSize, circleSize)
		
		
		
		
## Get scaled coordinates given an (x, y)
func get_scale_coords(x: int, y: int) -> Vector2:
	return Vector2(x + offset.x, y + offset.y)


#func _process(_delta):
	#var pos = get_viewport().get_mouse_position()
	#print(pos)
