extends Control

@onready var panel_settings: Panel = $Panel_Settings
@onready var slider_bgm: HSlider = $Panel_Settings/VBoxContainer/ColorRect/HSlider
@onready var panel_upgrade: Panel = $Panel_Upgrade

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slider_bgm.value = MusicPlayer.volume
	MusicPlayer.connect("volume_changed", Callable(self, "_on_volume_changed"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_setting_pressed() -> void:
	panel_settings.visible = true


func _on_close_settings_pressed() -> void:
	panel_settings.visible = false
	panel_upgrade.visible = false


func _on_button_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/Main.tscn")

func _on_button_level_2_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main_level2.tscn")
	
func _on_slider_bgm_value_changed(value: float) -> void:
	MusicPlayer.set_bgm_volume(value)
	
func _on_volume_changed(value):
	# update slider jika diperlukan
	if slider_bgm.value != value:
		slider_bgm.value = value

func _on_button_upgrade_pressed() -> void:
	panel_upgrade.visible = true
