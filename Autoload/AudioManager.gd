extends Node


@export var audio : AudioStreamPlayer = AudioStreamPlayer.new()
@export var is_currently_playing : bool = false
@export var current_music : String = ""

func _ready():
	add_child(audio)

func play(audioPath: String):
	var localizeAudioPath = ProjectSettings.localize_path(audioPath)
	audio.stream = load(localizeAudioPath)
	audio.play()
	#started.emit()
	self.is_currently_playing = true
	self.current_music = localizeAudioPath
	
	print("AudioManager ", self.current_music)

	#Logger.console(3, ["[Audio Manager] Currently playing:", self.current_music])
