extends Control

@onready var songsList = $SongsList
@onready var bg = $BG

var songsListIndex : int = 0
var selectedSongPath : String = ""



# Called when the node enters the scene tree for the first time.
func _ready():
	init_song_list()
	
	play_selected_song()


## Initializes the SongsList list with songs under the 'Songs/' directory
func init_song_list() -> void:
	
	var songs = BeatmapManager.read_songs_directory()
	
	for song in songs:
		songsList.add_item(song)
	
	set_selected_song_path()
	set_selected_bg()

## Set bg to be displayed given the selected song
func set_selected_bg() -> void:
	var songDirPath = BeatmapManager.songsDirPath + selectedSongPath
	var songDir = DirAccess.open(songDirPath)
	var songs = BeatmapManager.read_directory(songDir)
	var textureFile = ""
	for bg in songs:
		if bg.to_lower().ends_with(".jpg") or bg.to_lower().ends_with(".png"):
			textureFile = bg
	
	var texturePath = BeatmapManager.concat_paths([
		songDirPath, textureFile
	])
	
	var localizeTexturePath = ProjectSettings.localize_path(texturePath)
	
	bg.set_texture(load(localizeTexturePath))
	


## Helper function to set the song path to the selected song
func set_selected_song_path() -> void:
	selectedSongPath = songsList.get_item_text(songsListIndex)
	play_selected_song()

## Plays the selected song
func play_selected_song() -> void:
	var songDirPath = BeatmapManager.songsDirPath + selectedSongPath
	var songDir = DirAccess.open(songDirPath)
	var songs = BeatmapManager.read_directory(songDir)
	var songFile = ""
	for song in songs:
		if song.to_lower().ends_with(".mp3"):
			songFile = song
	
	#var songPath = songDirPath + songFile
	var songPath = BeatmapManager.concat_paths([
		songDirPath, songFile
	])
	SoundManager.play(songPath)


func _on_songs_list_item_selected(index):
	songsListIndex = index
	set_selected_song_path()
	set_selected_bg()


func _on_play_button_pressed():
	#var scene = load("res://Scenes/Testing/NaixTestScenes/TestMultiplayerScene.tscn").instantiate()
	SoundManager.stop_current_audio()
	var scene = load("res://Scenes/Main.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()
