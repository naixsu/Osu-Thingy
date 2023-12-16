extends Node

@export_file("*.txt") var beatmap 
@export_file("*.jpg") var mapBG

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

func set_beatmap(songDirPath: String) -> void:
	var songDir = DirAccess.open(songDirPath)
	var songs = read_directory(songDir)
	var beatmapFile = ""
	var textureFile = ""
	
	for file in songs:
		if file.to_lower().ends_with(".txt"):
			beatmapFile = file
		if file.to_lower().ends_with(".jpg") or file.to_lower().ends_with(".png"):
			textureFile = file
	
	var beatmapPath = concat_paths([
		songDirPath, beatmapFile
	])
	
	var texturePath = BeatmapManager.concat_paths([
		songDirPath, textureFile
	])
	
	var localizeBeatmapPath = ProjectSettings.localize_path(beatmapPath)
	beatmap = localizeBeatmapPath
	
	var localizeTexturePath = ProjectSettings.localize_path(texturePath)
	mapBG = localizeTexturePath
