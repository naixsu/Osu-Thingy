extends Control

@onready var songsList = $SongsList

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


## Helper function to set the song path to the selected song
func set_selected_song_path() -> void:
	selectedSongPath = songsList.get_item_text(songsListIndex)

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
	AudioManager.play(songPath)


func _on_songs_list_item_selected(index):
	songsListIndex = index
	set_selected_song_path()
