extends Node

@export var beatmaps : Array[Resource]


@onready var audio : AudioStreamPlayer2D = $Audio

var path = "D:\\osu!\\Songs"


# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	var mp3 : AudioStream = beatmaps[i].mp3
	var beatmap = beatmaps[i].beatmap
	
	set_audio_stream(mp3)
	#audio.play()
	read_osu_file(beatmap)


## Set the AudioStreamPlayer's stream
func set_audio_stream(mp3: AudioStream) -> void:
	audio.set_stream(mp3)

## Read a .txt file that was converted to an .osu file and parse it
func read_osu_file(beatmap: String) -> void:
	var file = FileAccess.open(beatmap, FileAccess.READ)
	var text = file.get_as_text()
	
	print(text)
	
