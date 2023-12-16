extends Control

@onready var audio_stream_player_2d = $AudioStreamPlayer2D

@onready var songsList = $SongsList

var songsDirPath : String = "Songs/"
var songsDir : DirAccess
var songsListIndex : int = 0
var selectedSongPath : String = ""



# Called when the node enters the scene tree for the first time.
func _ready():
	songsDir = DirAccess.open(songsDirPath)
	
	init_song_list()


## Initializes the SongsList list with songs under the 'Songs/' directory
func init_song_list() -> void:
	
	var songs = songsDir.get_directories()
	
	for song in songs:
		songsList.add_item(song)
	
	set_selected_song_path()


## Helper function to set the song path to the selected song
func set_selected_song_path():
	selectedSongPath = songsList.get_item_text(songsListIndex)


func _on_songs_list_item_selected(index):
	songsListIndex = index
	set_selected_song_path()
