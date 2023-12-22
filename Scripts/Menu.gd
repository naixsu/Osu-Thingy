extends Control

@onready var songsList : ItemList = $SongsList
@onready var bg : TextureRect = $BG
@onready var songPickTimer : Timer = $Timers/SongPickTimer

var songsListIndex : int = 0
var selectedSongPath : String = ""
var beatmapPath : String = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	init_song_list()
	


## Initializes the SongsList list with songs under the 'Songs/' directory
func init_song_list() -> void:
	clear_song_list()
	var songs = BeatmapManager.read_songs_directory()
	
	for song in songs:
		songsList.add_item(song)
	
	set_selected_song_path()
	set_selected_bg()
	set_selected_beatmap()
	
	play_selected_song()

## Clear song list if populated
func clear_song_list() -> void:
	songsList.clear()
		

## Set bg to be displayed given the selected song
func set_selected_bg() -> void:
	var songDirPath = BeatmapManager.songsDirPath + selectedSongPath
	var songDir = DirAccess.open(songDirPath)
	var songs = BeatmapManager.read_directory(songDir)
	var textureFile = ""
	for file in songs:
		if file.to_lower().ends_with(".jpg") or file.to_lower().ends_with(".png"):
			textureFile = file
	
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
	for file in songs:
		if file.to_lower().ends_with(".mp3"):
			songFile = file
	
	var songPath = BeatmapManager.concat_paths([
		songDirPath, songFile
	])
	SoundManager.play(songPath)


## Set the selected beatmap to be also used by BeatmapManager
func set_selected_beatmap() -> void:
	var songDirPath = BeatmapManager.songsDirPath + selectedSongPath
	#var songDir = DirAccess.open(songDirPath)
	#var songs = BeatmapManager.read_directory(songDir)
	#var beatmapFile = ""
	#for file in songs:
		#if file.to_lower().ends_with(".txt"):
			#beatmapFile = file
	#
	#beatmapPath = BeatmapManager.concat_paths([
		#songDirPath, beatmapFile
	#])
	
	#print(beatmapPath)
	BeatmapManager.set_beatmap(songDirPath)

## Function to set the selected song on double click
func set_selected_song(index: int) -> void:
	if not songPickTimer.is_stopped() and index == songsListIndex:
		play_game()
	
	songPickTimer.start()

func play_game() -> void:
	SoundManager.stop_current_audio()
	var scene = load("res://Scenes/Main.tscn").instantiate()
	scene.name = "Main"
	get_tree().root.add_child(scene)
	self.hide()


func _on_songs_list_item_selected(index):
	if index == songsListIndex:
		return
	songsListIndex = index
	set_selected_song_path()
	set_selected_bg()
	set_selected_beatmap()



func _on_play_button_pressed():
	#var scene = load("res://Scenes/Testing/NaixTestScenes/TestMultiplayerScene.tscn").instantiate()
	play_game()
	#self.queue_free()


func _on_songs_list_item_clicked(index, at_position, mouse_button_index):
	set_selected_song(index)
