extends Node

@onready var hitSound : AudioStreamPlayer = $HitSound
@onready var comboBreak : AudioStreamPlayer = $ComboBreak
@onready var failSound : AudioStreamPlayer = $FailSound
@onready var audio : AudioStreamPlayer = $Audio

@export var is_currently_playing : bool = false
@export var current_music : String = ""

signal finished_song

## Plays the audio given an audioPath
func play(audioPath: String) -> void:
	stop_current_audio()
	var localizePath = ProjectSettings.localize_path(audioPath)
	audio.stream = load(localizePath)
	audio.play()
	#started.emit()
	is_currently_playing = true
	current_music = localizePath
	
	#print("AudioManager ", current_music)

## Stops the current playing audio if any
func stop_current_audio() -> void:
	if audio.is_playing():
		#print("AUdioManager stopped playing, ", current_music)
		audio.stop()


func _on_audio_finished():
	finished_song.emit()
