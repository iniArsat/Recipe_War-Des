extends Control

@onready var panel_upgrade: Panel = $Panel_Upgrade
@onready var panel_credit: Panel = $Panel_Credit
@onready var panel_settings: Panel = $Panel_Settings
@onready var slider_bgm: HSlider = $Panel_Settings/VBoxContainer/ColorRect/HSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slider_bgm.value = MusicPlayer.volume
	MusicPlayer.connect("volume_changed", Callable(self, "_on_volume_changed"))


func _on_button_upgrade_pressed() -> void:
	panel_upgrade.visible = true


func _on_close_upgrade_pressed() -> void:
	panel_upgrade.visible = false
	panel_credit.visible = false
	panel_settings.visible = false

func _on_button_credit_pressed() -> void:
	panel_credit.visible = true


func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/select_level.tscn")


func _on_button_setting_pressed() -> void:
	panel_settings.visible = true
	
func _on_slider_bgm_value_changed(value: float) -> void:
	MusicPlayer.set_bgm_volume(value)
	
func _on_volume_changed(value):
	# update slider jika diperlukan
	if slider_bgm.value != value:
		slider_bgm.value = value
