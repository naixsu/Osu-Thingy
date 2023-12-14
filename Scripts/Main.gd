extends Node
class_name Main

@export var Note : PackedScene

@export var beatmaps : Array[Resource]

@onready var noteGroup = $NoteGroup
@onready var audio : AudioStreamPlayer2D = $Audio
@onready var songTimer : Timer = $SongTimer

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
var timeElapsed : float = 0.0
var index = 0
var circleSize : float

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	var mp3 : AudioStream = beatmaps[i].mp3
	var beatmap = beatmaps[i].beatmap
	read_osu_file(beatmap)
	circleSize = float(metadata["Difficulty"]["CircleSize"])
	#print(metadata["Difficulty"])
	set_audio_stream(mp3)
	audio.play()
	# Get the song length in ms
	songLength = set_song_length()
	# Turn back timer to s from ms
	songTimer.wait_time = songLength / 1000 
	songTimer.start()
	#place_obects(metadata["HitObjects"])
	print(metadata["HitObjects"].size())

func _physics_process(delta):
	#print(songTimer.time_left)
	if index >= metadata["HitObjects"].size():
		print("Stop")
		return
		
	timeElapsed += delta
	var timeMS = int(timeElapsed * 1000)
	var threshold = 15 # threshold of 15 ms
	var timeDifference = abs(timeMS - metadata["HitObjects"][index]["time"])
	
	if timeDifference <= threshold:
		place_single_object(metadata["HitObjects"][index])
		index += 1


#region Init
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
	var currentMetadata : String = ""
	
	while not file.eof_reached():
		var line = file.get_line()

		if "[General]" in line:
			currentMetadata = line
		if "[Metadata]" in line:
			currentMetadata = line
		if "[Difficulty]" in line:
			currentMetadata = line
		if "[HitObjects]" in line:
			currentMetadata = line
		
		match currentMetadata:
			"[General]":
				var keyValue = line.split(':')
				if len(keyValue) == 2:
					metadata["General"][keyValue[0]] = keyValue[1]
			"[Metadata]":
				var keyValue = line.split(':')
				if len(keyValue) == 2:
					metadata["Metadata"][keyValue[0]] = keyValue[1]
			"[Difficulty]":
				var keyValue = line.split(':')
				if len(keyValue) == 2:
					metadata["Difficulty"][keyValue[0]] = keyValue[1]
			"[HitObjects]":
				var rawData = line.split(',')
				
				if len(rawData) >= 4:
					var data = {
							'x'     : rawData[0].to_int(),
							'y'     : rawData[1].to_int(),
							'time'  : rawData[2].to_int(),
							'type'  : rawData[3].to_int(),
						}
					if data["type"] & 2: # Check if the second bit is set. This is for slider
						var sliderPoints = rawData[5]
						var rawSliderPoints = sliderPoints.split("|")
						data["sliderReverses"] = rawData[6].to_int()
						data["sliderLength"] = rawData[7].to_float()
						
						data["sliderData"] = analyze_slider({
							"x" : data["x"],
							"y" : data["y"],
							"time" : data["time"],
							"type" : data["type"],
							"sliderPoints" : rawSliderPoints,
							"sliderReverses" : data["sliderReverses"],
							"sliderLength" : data["sliderLength"]
						})

					metadata["HitObjects"].append(data)
	file.close()

#endregion

#region Slider stuff
## Analyzing the slider to determine the proper slider data to be returned
func analyze_slider(note: Dictionary) -> Dictionary:
	if note["type"] & 2 == 0:
		print("Error in analyzeSlider at " + note.time + ": Not a slider")
		return {}
	
	var pts = note["sliderPoints"]
	var sliderType = pts[0]
	
	if pts.size() == 2:
		sliderType = "L"
	
	match sliderType:
		"L", "C":
			return {
				"type" : sliderType,
				"points" : get_linear_point(pts)
			}
		"B":
			return {
				"type" : sliderType,
				"points" : get_bezier_points(pts)
			}
		"P":
			return {
				"type" : sliderType,
				"points" : get_path_points(pts)
			}
		_:
			return {}

## Returns the end point of a linear slider
func get_linear_point(pts: Array[String]) -> Vector2:
	return get_vector(pts[1])

## Returns an array of points
func get_path_points(pts: Array[String]) -> Array:
	var arr = []
	
	for i in range(1, pts.size()):
		arr.append(get_vector(pts[i]))
	
	return arr
	
## Returns an array of points without duplicates as bezier nature
func get_bezier_points(pts: Array[String]) -> Array:
	var arr = []
	
	for i in range(1, pts.size()):
		var currPoint = get_vector(pts[i])
		
		if currPoint not in arr:
			arr.append(currPoint)
	
	return arr

#endregion


## Places objects in the play area (scaled)
func place_obects(hitObjects: Array) -> void:
	for obj in hitObjects:
		place_single_object(obj)
		
		break
## Places a single object in the play area (scaled)		
func place_single_object(obj: Dictionary) -> void:
	var x = obj["x"]
	var y = obj["y"]
	var time = obj["time"]
	var type = obj["type"]
	var scaledXY = get_scale_coords(x, y)
	
	var note = Note.instantiate()
	noteGroup.add_child(note)
	note.timer.start()
	note.global_position = scaledXY
	note.scale = Vector2(circleSize, circleSize)
	
	if type == 2 or type == 6:
		place_slider(obj)

func place_slider(obj: Dictionary) -> void:
	print(obj)
	pass
		
		
#region General methods
## Returns a Vector2 from a string with format "x:y"
func get_vector(point: String) -> Vector2:
	var p = point.split(":")
	var x = p[0].to_int()
	var y = p[1].to_int()
	
	return Vector2(x, y)

## Get scaled coordinates given an (x, y)
func get_scale_coords(x: int, y: int) -> Vector2:
	return Vector2(x + offset.x, y + offset.y)

#endregion
