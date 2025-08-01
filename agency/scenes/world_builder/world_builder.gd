# world_builder.gd
extends Control

# --- UI Node References ---
@onready var nav_buttons_container = $HSplitContainer/NavPane/NavLayout/NavButtonsContainer
@onready var list_title = $HSplitContainer/ContentSplitter/AssetListPane/ListLayout/PanelContainer/ListTitle
@onready var asset_list_container = $HSplitContainer/ContentSplitter/AssetListPane/ListLayout/ScrollContainer/AssetListContainer
@onready var detail_placeholder = $HSplitContainer/ContentSplitter/DetailPane/DetailPlaceholder
@onready var form_view = $HSplitContainer/ContentSplitter/DetailPane/FormView
@onready var card_title = $HSplitContainer/ContentSplitter/DetailPane/FormView/HBoxContainer/PanelContainer/ImageSectionLayout/CardTitle
@onready var form_tabs = $HSplitContainer/ContentSplitter/DetailPane/FormView/HBoxContainer/FormSectionLayout/TabContainer
@onready var cancel_button = $HSplitContainer/ContentSplitter/DetailPane/FormView/HBoxContainer/FormSectionLayout/FooterButtons/CancelButton
@onready var save_button = $HSplitContainer/ContentSplitter/DetailPane/FormView/HBoxContainer/FormSectionLayout/FooterButtons/SaveButton

# --- Data ---
const RESOURCE_PATHS = {
	"Characters": "res://scripts/resources/character_resource.gd",
	"Locations": "res://scripts/resources/location_resource.gd",
	"Items": "res://scripts/resources/item_resource.gd",
	"Factions": "res://scripts/resources/faction_resource.gd",
	"Districts": "res://scripts/resources/district_resource.gd",
}

const ICON_PATHS = {
	"Characters": "res://assets/icon_char.svg",
	"Locations": "res://assets/icon_loc.svg",
	"Items": "res://assets/icon_item.svg",
	"Factions": "res://assets/icon_faction.svg",
	"Districts": "res://assets/icon_district.svg",
}

var asset_types: Dictionary = {}
var current_asset_type: String = ""
var current_resource: Resource = null

const AssetNavButton = preload("res://scenes/ui/asset_nav_button.tscn")
const AssetListItem = preload("res://scenes/ui/asset_list_item.tscn")

# --- Godot Functions ---

func _ready():
	_scan_for_resources()
	_setup_navigation()
	
	if not asset_types.is_empty():
		select_asset_type(asset_types.keys()[0])
	
	cancel_button.pressed.connect(_on_cancel_pressed)
	save_button.theme_type_variation = "Save"
	cancel_button.theme_type_variation = "Button"
	save_button.pressed.connect(_on_save_pressed)

# --- Data Handling ---

func _scan_for_resources():
	asset_types.clear()
	for type_name in RESOURCE_PATHS:
		asset_types[type_name] = {"label": type_name, "items": [], "script_path": RESOURCE_PATHS[type_name]}
		
	var dir = DirAccess.open("res://cases")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var resource = load("res://cases/" + file_name)
				if resource and resource.get_script():
					for type_name in asset_types:
						if resource.get_script().get_path() == asset_types[type_name].script_path:
							asset_types[type_name].items.append(resource)
			file_name = dir.get_next()

# --- Name Helper ---
func _get_resource_name(resource: Resource) -> String:
	if not is_instance_valid(resource):
		return "Invalid Resource"
	
	const NAME_PROPERTIES = ["full_name", "location_name", "item_name", "faction_name", "district_name", "name"]
	for prop in NAME_PROPERTIES:
		if resource.has(prop):
			var value = resource.get(prop)
			if value is String and not value.is_empty():
				return value
				
	return "Unnamed Resource"

# --- UI Setup ---

func _setup_navigation():
	for child in nav_buttons_container.get_children():
		child.queue_free()
	
	# Add a spacer at the top
	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav_buttons_container.add_child(top_spacer)

	for type_key in asset_types:
		var data = asset_types[type_key]
		var nav_button = AssetNavButton.instantiate()
		nav_buttons_container.add_child(nav_button)
		nav_button.set_label(data.label)
		if ICON_PATHS.has(type_key):
			nav_button.set_icon(ICON_PATHS[type_key])
		nav_button.pressed.connect(select_asset_type.bind(type_key))

	# Add a spacer at the bottom
	var bottom_spacer = Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav_buttons_container.add_child(bottom_spacer)

func _update_asset_list():
	for child in asset_list_container.get_children():
		child.queue_free()
	
	if not asset_types.has(current_asset_type):
		return

	var type_data = asset_types[current_asset_type]
	list_title.text = type_data.label
	list_title.add_theme_stylebox_override("normal", get_theme_stylebox("panel", "PanelContainer"))
	list_title.add_theme_font_override("font", get_theme_font("font", "Title"))
	list_title.add_theme_font_size_override("font_size", 28)
	
	var new_button = Button.new()
	new_button.theme_type_variation = "Save"
	new_button.text = "New %s" % type_data.label.trim_suffix("s")
	new_button.pressed.connect(show_detail_view.bind(null))
	asset_list_container.add_child(new_button)
	
	for resource in type_data.items:
		var list_item = AssetListItem.instantiate()
		asset_list_container.add_child(list_item)
		list_item.set_data(resource)
		list_item.custom_signal.connect(show_detail_view)

func _generate_form_for_resource(resource: Resource):
	for child in form_tabs.get_children():
		child.queue_free()
	form_tabs.clear_tabs()

	if not is_instance_valid(resource):
		return

	var properties = resource.get_script().get_script_property_list()
	var general_tab = VBoxContainer.new()
	general_tab.name = "General"
	form_tabs.add_child(general_tab)
	form_tabs.set_tab_title(0, "General")

	for p in properties:
		if p.usage & PROPERTY_USAGE_EDITOR:
			var field_container = HBoxContainer.new()
			field_container.name = p.name + "Field"

			var label = Label.new()
			label.text = p.name.capitalize().replace("_", " ")
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			var editor = _get_editor_for_property(p, resource)
			editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			field_container.add_child(label)
			field_container.add_child(editor)
			general_tab.add_child(field_container)

func _get_editor_for_property(p: Dictionary, resource: Resource) -> Node:
	var editor
	var current_value = resource.get(p.name)

	match p.type:
		TYPE_STRING:
			if p.hint == PROPERTY_HINT_MULTILINE_TEXT:
				editor = TextEdit.new()
				editor.custom_minimum_size.y = 100
			else:
				editor = LineEdit.new()
			editor.text = current_value or ""
		TYPE_INT, TYPE_FLOAT:
			editor = SpinBox.new()
			editor.allow_lesser = true
			editor.allow_greater = true
			editor.value = current_value or 0
		TYPE_BOOL:
			editor = CheckBox.new()
			editor.button_pressed = current_value or false
		TYPE_ARRAY, TYPE_DICTIONARY:
			editor = TextEdit.new()
			editor.custom_minimum_size.y = 100
			editor.text = JSON.stringify(current_value)
		_:
			editor = LineEdit.new()
			editor.text = str(current_value)
			editor.editable = false
	
	editor.name = p.name
	return editor

# --- UI State ---

func select_asset_type(type_key: String):
	current_asset_type = type_key
	current_resource = null
	hide_detail_view()
	_update_asset_list()

func show_detail_view(resource):
	var type_data = asset_types[current_asset_type]
	
	if is_instance_valid(resource):
		current_resource = resource
		card_title.text = _get_resource_name(resource)
		_generate_form_for_resource(resource)
	else: # New resource
		card_title.text = "New %s" % type_data.label.trim_suffix("s")
		var new_res_script = load(type_data.script_path)
		current_resource = new_res_script.new()
		_generate_form_for_resource(current_resource)
		
	detail_placeholder.hide()
	form_view.show()

func hide_detail_view():
	form_view.hide()
	detail_placeholder.show()

# --- Signal Handlers ---

func _on_cancel_pressed():
	hide_detail_view()

func _on_save_pressed():
	if not is_instance_valid(current_resource):
		return

	var properties = current_resource.get_script().get_script_property_list()
	var form_tab = form_tabs.get_child(0)

	for p in properties:
		if p.usage & PROPERTY_USAGE_EDITOR:
			var field_container = form_tab.get_node_or_null(p.name + "Field")
			if is_instance_valid(field_container):
				var editor = field_container.get_node_or_null(p.name)
				if is_instance_valid(editor):
					var value
					match p.type:
						TYPE_STRING:
							value = editor.text
						TYPE_INT, TYPE_FLOAT:
							value = editor.value
						TYPE_BOOL:
							value = editor.button_pressed
						TYPE_ARRAY, TYPE_DICTIONARY:
							var parse_result = JSON.parse_string(editor.text)
							if parse_result:
								value = parse_result
							else:
								push_error("Invalid JSON in form for property: " + p.name)
					
					if value != null:
						current_resource.set(p.name, value)

	var path = current_resource.resource_path
	if path.is_empty():
		var type_label = asset_types[current_asset_type].label.to_lower()
		var resource_name = _get_resource_name(current_resource).to_snake_case()
		if resource_name == "unnamed_resource":
			resource_name = str(Time.get_unix_time_from_system())
		path = "res://cases/%s_%s.tres" % [type_label.trim_suffix("s"), resource_name]
		
	var save_error = ResourceSaver.save(current_resource, path)
	if save_error != OK:
		push_error("Failed to save resource to path: %s" % path)
		return

	# Refresh the list
	_scan_for_resources()
	_update_asset_list()
	hide_detail_view()
