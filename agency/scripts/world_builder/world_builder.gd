# agency/scripts/world_builder/world_builder.gd
extends Control

# --- UI Node References ---
@onready var resource_tree: Tree = $HSplitContainer/VBoxContainer/ResourceTree
@onready var name_edit: LineEdit = $HSplitContainer/ScrollContainer/EditorPanel/HBoxContainer/NameEdit
@onready var description_edit: TextEdit = $HSplitContainer/ScrollContainer/EditorPanel/HBoxContainer2/DescriptionEdit
@onready var save_button: Button = $HSplitContainer/ScrollContainer/EditorPanel/HBoxContainer3/SaveButton
@onready var new_button: Button = $HSplitContainer/ScrollContainer/EditorPanel/HBoxContainer3/NewButton
@onready var back_button: Button = $BackButton

# --- Constants and Variables ---
const WORLD_DATA_PATH = "res://worlds/default/"
var main_menu_scene = preload("res://scenes/main_ui/main.tscn")
var current_resource: Resource = null


func _ready() -> void:
	# --- Connect Signals ---
	back_button.pressed.connect(_on_back_button_pressed)
	resource_tree.item_selected.connect(_on_resource_tree_item_selected)
	save_button.pressed.connect(_on_save_button_pressed)
	new_button.pressed.connect(_on_new_button_pressed)

	# --- Initial Setup ---
	_populate_resource_tree()
	_clear_editor_panel()
	# Disable the editor until a resource is selected or created
	$HSplitContainer/ScrollContainer.visible = false


# --- Signal Handlers ---

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_menu_scene)

func _on_resource_tree_item_selected() -> void:
	_clear_editor_panel()

	var selected_item: TreeItem = resource_tree.get_selected()
	if not selected_item:
		current_resource = null
		return

	var file_path = selected_item.get_metadata(0)
	if file_path and ResourceLoader.exists(file_path):
		current_resource = ResourceLoader.load(file_path)
		_populate_editor_panel(current_resource)
		$HSplitContainer/ScrollContainer.visible = true

func _on_save_button_pressed() -> void:
	if not current_resource:
		return # Can't save if nothing is loaded

	# Update the resource properties from the UI fields
	current_resource.name = name_edit.text
	current_resource.description = description_edit.text

	# Save the resource back to its file
	var error = ResourceSaver.save(current_resource)
	if error != OK:
		print("Error saving resource: ", error)
	else:
		print("Resource saved successfully to: ", current_resource.resource_path)
		# Refresh the tree to show any name changes
		_populate_resource_tree()

func _on_new_button_pressed() -> void:
	# Create a new instance of a DistrictResource
	var new_district = load("res://scripts/resources/district_resource.gd").new()

	# Give it a temporary name and path
	var new_filename = "district_%s.tres" % Time.get_unix_time_from_system()
	new_district.resource_path = WORLD_DATA_PATH.path_join(new_filename)
	new_district.name = "New District"

	# Set it as the current resource and populate the editor
	current_resource = new_district
	_populate_editor_panel(current_resource)
	$HSplitContainer/ScrollContainer.visible = true
	name_edit.grab_focus() # Put the cursor in the name field


# --- Helper Functions ---

func _populate_resource_tree() -> void:
	resource_tree.clear()
	var root = resource_tree.create_item()
	resource_tree.hide_root = true

	var districts_item = resource_tree.create_item(root)
	districts_item.set_text(0, "Districts")
	districts_item.set_selectable(0, false) # Make the category non-selectable

	# Use DirAccess to find all .tres files in our world data path
	var dir = DirAccess.open(WORLD_DATA_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var full_path = WORLD_DATA_PATH.path_join(file_name)
				var resource = ResourceLoader.load(full_path)

				# Check if it's a DistrictResource before adding
				if resource is DistrictResource:
					var tree_item = resource_tree.create_item(districts_item)
					tree_item.set_text(0, resource.name)
					tree_item.set_metadata(0, full_path) # Store the path in the item

			file_name = dir.get_next()
	else:
		print("Could not open directory: ", WORLD_DATA_PATH)

func _populate_editor_panel(resource: Resource) -> void:
	if resource is DistrictResource:
		name_edit.text = resource.name
		description_edit.text = resource.description
	else:
		_clear_editor_panel()

func _clear_editor_panel() -> void:
	name_edit.clear()
	description_edit.clear()
	$HSplitContainer/ScrollContainer.visible = false
	current_resource = null
