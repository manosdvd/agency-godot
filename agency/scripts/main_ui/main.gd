# agency/scripts/main_ui/main.gd
extends Control

# Preload the scenes we will switch to.
# Using packed scenes is more efficient than loading by string path every time.
var world_builder_scene = preload("res://scenes/world_builder/world_builder.tscn")
var case_creator_scene = preload("res://scenes/case_creator/case_creator.tscn")
var validator_scene = preload("res://scenes/validator/validator.tscn")

func _ready():
	# Connect the button signals to functions in this script.
	# We connect the "pressed" signal which is emitted when a button is clicked.
	$CenterContainer/VBoxContainer/WorldBuilderButton.pressed.connect(_on_world_builder_button_pressed)
	$CenterContainer/VBoxContainer/CaseCreatorButton.pressed.connect(_on_case_creator_button_pressed)
	$CenterContainer/VBoxContainer/ValidatorButton.pressed.connect(_on_validator_button_pressed)
	$CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

# This function will be called when the World Builder button is pressed.
func _on_world_builder_button_pressed():
	# The get_tree().change_scene_to_packed() function unloads the current scene
	# and loads the new one.
	get_tree().change_scene_to_packed(world_builder_scene)

# This function will be called when the Case Creator button is pressed.
func _on_case_creator_button_pressed():
	get_tree().change_scene_to_packed(case_creator_scene)

# This function will be called when the Validator button is pressed.
func _on_validator_button_pressed():
	get_tree().change_scene_to_packed(validator_scene)

# This function will be called when the Quit button is pressed.
func _on_quit_button_pressed():
	# get_tree().quit() safely closes the application.
	get_tree().quit()
