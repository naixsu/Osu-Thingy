extends Node


var songsDirPath : String = "Songs/"
var songsDir : DirAccess
var songsListIndex : int = 0
var selectedSongPath : String = ""


# Called when the node enters the scene tree for the first time.
func _ready():
	songsDir = DirAccess.open(songsDirPath)
	
	
## Initializes the SongsList list with songs under the 'Songs/' directory
func read_songs_directory() -> PackedStringArray:
	if songsDir:
		return songsDir.get_directories()
	return []

## General function to read directory and get files
func read_directory(dir: DirAccess) -> PackedStringArray:
	if dir:
		return dir.get_files()
	return []

## General function to concat files
func concat_paths(paths: Array) -> String:
	return "/".join(paths)
