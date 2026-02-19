extends Menu

#Labels for sliders
var masterLabel: Label
var musicLabel: Label
var menuLabel: Label
var inGameLabel: Label

#BusIndexes
var masterBus: int
var musicBus: int
var menuBus: int
var inGameBus: int

#Sliders
var masterHSlider: HSlider
var musicHSlider: HSlider
var menuHSlider: HSlider
var inGameHSlider: HSlider

func _ready():
	connect_buttons()
	#Assigns labels
	masterLabel = get_node("%MasterLabel")
	musicLabel = get_node("%MusicLabel")
	menuLabel = get_node("%MenuLabel")
	inGameLabel = get_node("%InGameLabel")
	
	#Assigns bus indexes
	masterBus = AudioServer.get_bus_index("Master")
	musicBus = AudioServer.get_bus_index("Music")
	menuBus = AudioServer.get_bus_index("MenuSFX")
	inGameBus = AudioServer.get_bus_index("ThreeDSFX")
	
	#Assigns hslider nodes
	masterHSlider = get_node("%MasterHSlider")
	musicHSlider = get_node("%MusicHSlider")
	menuHSlider = get_node("%MenuHSlider")
	inGameHSlider = get_node("%InGameHSlider")
	
	#Assigns hslider values
	masterHSlider.value = OptionsData.masterVolume
	musicHSlider.value = OptionsData.musicVolume
	menuHSlider.value = OptionsData.menuVolume
	inGameHSlider.value = OptionsData.inGameVolume

func _on_h_slider_value_changed(value: float, extra_arg_0: String) -> void:
	match extra_arg_0:
		"Master":
			var masterVolumeDisplayed: int = int(value * 100)
			masterLabel.text = "Master: " + str(masterVolumeDisplayed)
			AudioServer.set_bus_volume_db(masterBus, linear_to_db(value))
			OptionsData.masterVolume = value
		
		"Music":
			var musicVolumeDisplayed: int = int(value * 100)
			musicLabel.text = "Music: " + str(musicVolumeDisplayed)
			AudioServer.set_bus_volume_db(musicBus, linear_to_db(value))
			OptionsData.musicVolume = value
		
		"Menu":
			var menuVolumeDisplayed: int = int(value * 100)
			menuLabel.text = "Menu: " + str(menuVolumeDisplayed)
			AudioServer.set_bus_volume_db(menuBus, linear_to_db(value))
			OptionsData.menuVolume = value
		
		"InGame":
			var inGameVolumeDisplayed: int = int(value * 100)
			inGameLabel.text = "In Game: " + str(inGameVolumeDisplayed)
			AudioServer.set_bus_volume_db(inGameBus, linear_to_db(value))
			OptionsData.inGameVolume = value
		
		_:
			push_error("No valid hslider chosen: " + extra_arg_0)
	#OptionsData.SaveAudioSettings()
	
func UpdateVolumesFromOptionsData() -> void:
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Master"),
		linear_to_db(OptionsData.masterVolume))
	
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("Music"),
		linear_to_db(OptionsData.musicVolume))
	
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("MenuSFX"),
		linear_to_db(OptionsData.menuVolume))
	
	AudioServer.set_bus_volume_db(
		AudioServer.get_bus_index("ThreeDSFX"),
		linear_to_db(OptionsData.inGameVolume))

func _on_reset_audio_button_down() -> void:
	OptionsData.RestoreDefaultAudio()
	
	masterHSlider.value = OptionsData.masterVolume
	musicHSlider.value = OptionsData.musicVolume
	menuHSlider.value = OptionsData.menuVolume
	inGameHSlider.value = OptionsData.inGameVolume
	
	UpdateVolumesFromOptionsData()


func _on_back_button_up() -> void:
	OptionsData.SaveAudioSettings()
