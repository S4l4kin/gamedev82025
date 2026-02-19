extends Node

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
