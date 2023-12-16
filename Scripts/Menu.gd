extends Control

var songsDir : DirAccess
var songsPath : String = "Songs/"

@onready var songsList = $SongsList

# Called when the node enters the scene tree for the first time.
func _ready():
	songsDir = DirAccess.open(songsPath)
	
	init_song_list()
	

## Initializes the SongsList list with songs under the 'Songs/' directory
func init_song_list() -> void:
	
	var songs = songsDir.get_directories()
	
	for song in songs:
		songsList.add_item(song)
