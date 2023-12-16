extends Node
class_name Main

@export var Note : PackedScene
@export var Cursor : PackedScene

@onready var noteGroup = $NoteGroup
@onready var songTimer : Timer = $SongTimer
@onready var playArea = $PlayArea/Area



var path = "D:\\osu!\\Songs"
var OGPlayArea : Vector2 = Vector2(512, 384)
var offset : Vector2 
var offsetDifference : Vector2
var songLength : float = 0
var metadata : Dictionary = {
	"General" : {},
	"Metadata": {},
	"Difficulty": {},
	"HitObjects": [],
}
var timeElapsed : float = 0.015 # add 15s coz osu starts at 00:00:015
var index = 0
var circleSize : float
var timeMS : int = 0
var threshold : int = 5 # threshold of 5 ms
var timeDifference : int = 0
var slider : bool = false
var sliderIndex : int = 0
var sliderObj : Dictionary
#var hitObjStart : float = 588.0
var hitObjStart : float = 0.0
var cursor : Node2D
var isDead : bool = false
var combo : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	init_cursor()
	get_play_area_size()
	read_osu_file(BeatmapManager.beatmap)
	circleSize = float(metadata["Difficulty"]["CircleSize"])
	#print(metadata["Difficulty"])
	SoundManager.audio.play()
	# Get the song length in ms
	songLength = get_song_length()
	# Turn back timer to s from ms
	songTimer.wait_time = songLength / 1000 
	songTimer.start()
	#place_obects(metadata["HitObjects"])
	#print(metadata["HitObjects"].size())
	
	# https://osu.ppy.sh/wiki/en/Beatmap/Approach_rate
	# https://www.desmos.com/calculator/ha9h7as3hx
	var objTime = metadata["HitObjects"][index]["time"]
	var ar = metadata["Difficulty"]["ApproachRate"].to_float()
	var preempt = 0
	#if ar < 5:
		#preempt = 0.8 + 0.4 * (5 - ar) / 5
	#elif ar == 5:
		#preempt = 0.8
	#else:
		#preempt = 0.8 - 0.5 * (ar - 5) / 5
	if ar < 5:
		preempt = 1.2 + 0.6 * (5 - ar) / 5
	elif ar == 5:
		preempt = 1.2
	else:
		preempt = 1.2 - 0.75 * (ar - 5) / 5
	preempt *= 1000
	print(preempt)


	print("Duration for AR ", ar , " : ", preempt)
	hitObjStart = preempt

func _process(_delta):
	update_cursor_position()
	
	#print(get_viewport().get_visible_rect().size)

func _physics_process(delta):
	
	if isDead:
		SoundManager.audio.stop()
		return

	if index >= metadata["HitObjects"].size():
		print("Stop")
		return

		
	timeElapsed += delta
	timeMS = int(timeElapsed * 1000)
	#print(timeMS)
	var objTime = metadata["HitObjects"][index]["time"]
	# using an offset here to start the approach circle
	# TODO: Update this offset
	var timeOffset = objTime - hitObjStart
	timeOffset += 25 # Arbitrary value
	
	timeDifference = abs(timeMS - timeOffset)
	
	#print(timeMS, " - ", timeOffset, " - ", timeDifference)
	
	if timeDifference <= threshold:
		#print("else timeDifference ", timeDifference)
		place_single_object(metadata["HitObjects"][index])
		index += 1
		
	#if slider:
		#place_slider()


#region Init
## Initializes the cursor and its signals
func init_cursor() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	cursor = Cursor.instantiate()
	cursor.connect("dead", dead)
	add_child(cursor)

## Set the song length in s to ms
func get_song_length() -> int:
	var length: float = SoundManager.audio.stream.get_length()
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
func get_linear_point(pts: Array[String]) -> Array:
	return [get_vector(pts[1])]

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
	#var time = obj["time"]
	var type = obj["type"]
	var scaledXY = get_scale_coords(x, y)
	
	print(x, " ", y, " ", scaledXY.x, " ", scaledXY.y)
	
	var note = Note.instantiate()
	noteGroup.add_child(note)
	note.hitCircle.set_self_modulate(Color(1, 1, 1, 0))
	note.approachRate = metadata["Difficulty"]["ApproachRate"].to_float()
	note.approachCircleTimer.wait_time = hitObjStart / 1000
	#note.queueFreeTimer.wait_time = 1
	# this could be optimized by making autostart on
	# each timers true but i decided to stick with
	# using the start() method
	#note.queueFreeTimer.start()
	note.approachCircleTimer.start()
	
	note.global_position = scaledXY
	note.scale = Vector2(circleSize, circleSize)
	
	if type == 6 or type == 5:
		combo = 1
	else:
		combo += 1
	
	note.combo.text = str(combo)
	
	#if type == 2 or type == 6:
		#place_slider(obj)
		#sliderObj = obj
		#sliderIndex = 0
		#slider = true
		

func place_slider(obj: Dictionary) -> void:
	var sliderLength : int = obj["sliderLength"]
	var sliderPoints : Array = obj["sliderData"]["points"]
	var sliderTimeMS = timeMS + sliderLength

	for point in sliderPoints:
		place_single_object({
			"x" : point.x,
			"y" : point.y,
			"type" : -1
			})
	pass
		
#func place_slider() -> void:
	#var sliderLength : int = sliderObj["sliderLength"]
	#var sliderPoints : Array = sliderObj["sliderData"]["points"]
	#var sliderTimeMS : int = sliderObj["time"]
	#var point : Vector2 = sliderPoints[sliderIndex]
	#var sliderTimeDifference = abs(timeMS - (sliderTimeMS + sliderLength * 4))
	#
	#if sliderTimeDifference <= threshold:
		#place_single_object({
			#"x" : point.x,
			#"y" : point.y,
			#"type" : -1
		#})
		#sliderIndex += 1
	#
	#if sliderIndex == sliderPoints.size():
		#slider = false
		#
#region General methods
## Returns a Vector2 from a string with format "x:y"
func get_vector(point: String) -> Vector2:
	var p = point.split(":")
	var x = p[0].to_int()
	var y = p[1].to_int()
	
	return Vector2(x, y)

## Get scaled coordinates given an (x, y)
func get_scale_coords(x: int, y: int) -> Vector2:
	#return Vector2(x + offset.x, y + offset.y)
	var scaledX = (x / OGPlayArea.x) * playArea.size.x + offsetDifference.x
	var scaledY = (y / OGPlayArea.y) * playArea.size.y + offsetDifference.y
	
	return Vector2(scaledX, scaledY)


func _scale_coordinates(original_x: float, original_y: float) -> Vector2:
	var original_min_x = 0.0
	var original_min_y = 0.0
	var original_max_x = OGPlayArea.x
	var original_max_y = OGPlayArea.y
	
	var target_min_x = offsetDifference.x
	var target_max_x = playArea.size.x + offsetDifference.x
	var target_min_y = offsetDifference.y
	var target_max_y = playArea.size.y + offsetDifference.y
	
	var scaled_x = lerp(target_min_x, target_max_x, inverse_lerp(original_min_x, original_max_x, original_x))
	var scaled_y = lerp(target_min_y, target_max_y, inverse_lerp(original_min_y, original_max_y, original_y))
	
	return Vector2(scaled_x, scaled_y)

## Update cursor position and clamps it based on the playArea
func update_cursor_position() -> void:
	cursor.position = get_viewport().get_mouse_position()
	#cursor.position.x = clamp(cursor.position.x, 116, playArea.x + 116)
	#cursor.position.y = clamp(cursor.position.y, 34, playArea.y + 34)

func dead() -> void:
	isDead = true

## Gets the current size of the playArea and also updates the offset
func get_play_area_size() -> void:
	if playArea != null:
		print(playArea.size)
		offset = playArea.size - OGPlayArea
		offsetDifference = playArea.position
		print("offset ", offset)
		print("offsetDifference ", offsetDifference)
		
#endregion


#region Signals
func _on_area_resized():
	get_play_area_size()

#endregion
