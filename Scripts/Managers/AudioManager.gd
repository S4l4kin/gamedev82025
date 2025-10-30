extends Node
class_name AudioManager

var instance: AudioManager

@export var MusicPlayer: AudioStreamPlayer
@export var GlobalSFXPlayer: AudioStreamPlayer
@export var TwoDSFXPlayer: AudioStreamPlayer2D

var _sfx := {}

func _enter_tree():	
	if instance and instance != self:
		queue_free()
		return
	instance = self

func _ready():
	if not MusicPlayer:
		MusicPlayer = $MusicPlayer
	if not GlobalSFXPlayer:
		GlobalSFXPlayer = $GlobalSFXPlayer
	if not TwoDSFXPlayer:
		TwoDSFXPlayer = $TwoDSFXPlayer

	#Preload audio files
	_sfx["test_click"] = preload("res://Assets/Resources/Audio/SFX/TestAudioClick.wav")

#Play music
func play_music(resourcePath: String, loop := true ):
	var stream := load(resourcePath)
	
	if not stream:
		push_error("Music could not be found at %s" % resourcePath)
		return

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
	

func play_2d_sfx(keyOrPath: String, position: Vector2, volumeDb := 0.0):
	var stream: AudioStream = null
		
	if _sfx.has(keyOrPath):
		stream = _sfx[keyOrPath]
	else:
		stream = load(keyOrPath)
	
	if not stream:
		push_error("SFX %s couldn't be found" % keyOrPath)
		return
	
	var player := AudioStreamPlayer2D.new()
	player.bus = "TwoDSFX"
	player.position = position
	player.stream = stream
	player.volume_db = volumeDb
	add_child(player)
	player.play()
	
	player.finished.connect(func(): if player.is_inside_tree(): player.queue_free())
