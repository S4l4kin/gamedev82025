extends Node

@export var MusicPlayer: AudioStreamPlayer
@export var MenuSFXPlayer: AudioStreamPlayer
@export var GlobalSFXPlayer: AudioStreamPlayer
@export var ThreeDSFXPlayer: AudioStreamPlayer3D

var _sfx := {}


func _ready():
	if not MusicPlayer:
		MusicPlayer = $MusicPlayer
	if not MenuSFXPlayer:
		MenuSFXPlayer = $MenuSFXPlayer
	if not GlobalSFXPlayer:
		GlobalSFXPlayer = $GlobalSFXPlayer
	if not ThreeDSFXPlayer:
		ThreeDSFXPlayer = $ThreeDSFXPlayer

	#Preload audio files
	_sfx["click"] = preload("res://Assets/Resources/Audio/SFX/Click.wav")
	_sfx["hover_card"] = preload("res://Assets/Resources/Audio/SFX/HoverCard.wav")
	_sfx["game_win"] = preload("res://Assets/Resources/Audio/SFX/GameWin.wav")
	_sfx["play_HQ"] = preload("res://Assets/Resources/Audio/SFX/PlayHQ.wav")
	_sfx["play_structure"] = preload("res://Assets/Resources/Audio/SFX/PlayStructure.wav")
	_sfx["play_spell"] = preload("res://Assets/Resources/Audio/SFX/PlaySpell.wav")
	_sfx["play_unit"] = preload("res://Assets/Resources/Audio/SFX/PlayUnit.wav")
	_sfx["your_turn"] = preload("res://Assets/Resources/Audio/SFX/YourTurn.wav")
	_sfx["unit_fight"] = preload("res://Assets/Resources/Audio/SFX/UnitFight.wav")
	_sfx["ranged_fight"] = preload("res://Assets/Resources/Audio/SFX/RangedFight.wav")
	
	#start menu music at game start
	play_music("res://Assets/Resources/Audio/Music/TerraIncognitaMenu.ogg")

#Play music
func play_music(resourcePath: String, loop := true ):
	var stream := load(resourcePath)
	
	if not stream:
		push_error("Music could not be found at %s" % resourcePath)
		return
	
	MusicPlayer.bus = "Music"
	MusicPlayer.stream = stream
	MusicPlayer.stream.loop = loop
	MusicPlayer.play()
	
#Stop music
func stop_music():
	if MusicPlayer:
		MusicPlayer.stop()
		
func play_menu_sfx(keyOrPath: String, volumeDb := 0.0):
	play_on_specific_bus(keyOrPath, "MenuSFX", volumeDb)
	
func play_global_sfx(keyOrPath: String, volumeDb := 0.0):
	play_on_specific_bus(keyOrPath, "GlobalSFX", volumeDb)

#Plays audio on the bus chosen above
func play_on_specific_bus(keyOrPath: String, busName: String, volumeDb := 0.0):
	var stream: AudioStream = null
	
	if _sfx.has(keyOrPath):
		stream = _sfx[keyOrPath]
	else:
		stream = load(keyOrPath)
	
	if not stream:
		push_error("SFX %s couldn't be found" % keyOrPath)
		return
		
	var player := AudioStreamPlayer.new()
	player.bus = busName
	player.stream = stream
	player.volume_db = volumeDb
	add_child(player)
	player.play()
	
	#Kill player
	player.finished.connect(func(): if player.is_inside_tree(): player.queue_free())
	

func play_3d_sfx(keyOrPath: String, position: Vector3, volumeDb := 0.0):
	var stream: AudioStream = null
		
	if _sfx.has(keyOrPath):
		stream = _sfx[keyOrPath]
	else:
		stream = load(keyOrPath)
	
	if not stream:
		push_error("SFX %s couldn't be found" % keyOrPath)
		return
	
	var player := AudioStreamPlayer3D.new()
	player.bus = "ThreeDSFX"
	player.position = position
	player.stream = stream
	player.volume_db = volumeDb
	add_child(player)
	player.play()
	
	player.finished.connect(func(): if player.is_inside_tree(): player.queue_free())

func play_3d_sfx_for_all(keyOrPath: String, position: Vector3, volumeDb := 0.0):
	if GameManager.network.is_host():
		play_3d_sfx(keyOrPath, position, volumeDb)
	
	GameManager.network.send_messages({"type":"play_3d_sfx", "key":keyOrPath, "pos": {"x": position.x, "y": position.y, "z": position.z}, "vol": volumeDb})
