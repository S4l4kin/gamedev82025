extends Node

var config : ConfigFile = ConfigFile.new()
var path : String = "user://UserSettings.cfg"
#Current audio settings
static var masterVolume: float = 0.75
static var musicVolume: float = 0.75
static var menuVolume: float = 0.75
static var inGameVolume: float = 0.75

#Default audio settings
const defaultMasterVolume: float = 0.75
const defaultMusicVolume: float = 0.75
const defaultMenuVolume: float = 0.75
const defaultInGameVolume: float = 0.75

#Restore default audio settings
static func RestoreDefaultAudio() -> void:
	masterVolume = defaultMasterVolume
	musicVolume = defaultMusicVolume
	menuVolume = defaultMenuVolume
	inGameVolume = defaultInGameVolume

func SaveAudioSettings():
	config.load(path)
	config.set_value("AUDIO", "masterVolume", masterVolume)
	config.set_value("AUDIO", "musicVolume", musicVolume)
	config.set_value("AUDIO", "menuVolume", menuVolume)
	config.set_value("AUDIO", "inGameVolume", inGameVolume)
	config.save(path)
	print("SETTINGS SAVED -----------------------")

func _ready():
	config.load(path)
	if config.get_value("AUDIO", "masterVolume") != null:
		masterVolume = config.get_value("AUDIO", "masterVolume")
	if config.get_value("AUDIO", "musicVolume") != null:
		musicVolume = config.get_value("AUDIO", "musicVolume")
	if config.get_value("AUDIO", "menuVolume") != null:
		menuVolume = config.get_value("AUDIO", "menuVolume")
	if config.get_value("AUDIO", "inGameVolume") != null:
		inGameVolume = config.get_value("AUDIO", "inGameVolume")
