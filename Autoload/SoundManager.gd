extends Node

@onready var hitSound = $HitSound
@onready var comboBreak = $ComboBreak
@onready var music = $Music

@export var is_currently_playing : bool = false
@export var current_music : String = ""

func play(audioPath: String):
	var localizeAudioPath = ProjectSettings.localize_path(audioPath)
	music.stream = load(localizeAudioPath)
	music.play()
	#started.emit()
	self.is_currently_playing = true
	self.current_music = localizeAudioPath
	
	print("AudioManager ", self.current_music)
