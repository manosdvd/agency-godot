# world_builder.gd
extends Control

# --- UI Node References ---
@onready var nav_buttons_container = $HSplitContainer/NavPane/NavLayout/NavButtonsContainer
@onready var asset_list_container = $HSplitContainer/ContentSplitter/AssetListPane/ListLayout/ScrollContainer/AssetListContainer
@onready var detail_placeholder = $HSplitContainer/ContentSplitter/DetailPane/DetailPlaceholder
@onready var form_view = $HSplitContainer/ContentSplitter/DetailPane/FormView
@onready var form_tab_container = $HSplitContainer/ContentSplitter/DetailPane/FormView/VBoxContainer/FormSectionLayout/FormTabContainer
@onready var cancel_button = $HSplitContainer/ContentSplitter/DetailPane/FormView/VBoxContainer/FooterButtons/CancelButton
@onready var save_button = $HSplitContainer/ContentSplitter/DetailPane/FormView/VBoxContainer/FooterButtons/SaveButton
@onready var image_file_dialog = $ImageFileDialog

# --- Dynamically Created Node References ---
var card_image_rect: TextureRect
var image_placeholder: VBoxContainer
var delete_image_button: Button

# --- Data ---
const RESOURCE_PATHS = {
	"Characters": "res://data/resources/character_resource.gd",
	"Locations": "res://data/resources/location_resource.gd",
	"Items": "res://data/resources/item_resource.gd",
	"Factions": "res://data/resources/faction_resource.gd",
	"Districts": "res://data/resources/district_resource.gd",
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
const AssetCard = preload("res://scenes/ui/asset_card.tscn")
const AlignmentEditor = preload("res://scenes/ui/alignment_editor.tscn")
const FORM_SECTIONS = {
	"Biography": ["full_name", "alias", "age", "gender", "employment", "biography"],
	"Relations": ["faction", "wealth_class", "district", "allies", "enemies", "items"],
	"Psychology": ["archetype", "personality", "values", "flaws_handicaps", "quirks", "characteristics", "alignment", "motivations", "secrets", "vulnerabilities"],
	"Author Notes": ["expertise", "honesty", "victim_likelihood", "killer_likelihood", "portrayal_notes", "dialogue_style", "voice_model", "primary_arc", "city"],
	"Meta": ["id", "is_sleuth"],
	"Default": [],
}
const PROPERTY_TOOLTIPS = {
	"full_name": "The character's complete, legal name.",
	"alias": "A nickname, codename, or other name the character goes by.",
	"age": "The character's age in years.",
	"biography": "A detailed history of the character's life, background, and significant events.",
	"faction": "The primary faction or organization this character is a member of.",
	"wealth_class": "The character's socioeconomic standing (e.g., 'Opulent', 'Working Class').",
	"district": "The district where the character primarily resides or operates.",
	"allies": "A list of other characters who are considered allies.",
	"enemies": "A list of other characters who are considered enemies.",
	"items": "A list of significant items this character owns or carries.",
	"archetype": "A classic storytelling archetype this character fits (e.g., 'Femme Fatale', 'Hard-boiled Detective').",
	"personality": "A description of the character's core personality traits.",
	"values": "What the character holds as most important.",
	"motivations": "The character's primary goals and driving forces.",
	"secrets": "Information the character is actively hiding from others.",
	"vulnerabilities": "Weaknesses, either physical or emotional, that could be exploited.",
	"honesty": "A 0-100 scale of how truthful this character tends to be.",
	"victim_likelihood": "A 0-100 author rating for how likely this character is to become a victim.",
	"killer_likelihood": "A 0-100 author rating for how likely this character is to be the culprit.",
	"is_sleuth": "Check this box if this character is the primary investigator of the case."
}

# --- New Constants ---
const SHORT_FIELDS = ["age", "is_sleuth", "honesty", "victim_likelihood", "killer_likelihood"]

var main_menu_scene = preload("res://scenes/main_ui/main.tscn")

# --- Godot Functions ---
func _ready():
	_scan_for_resources()
	_setup_navigation()
	if not asset_types.is_empty(): select_asset_type(asset_types.keys()[0])
	cancel_button.pressed.connect(_on_cancel_pressed)
	save_button.pressed.connect(_on_save_pressed)
	image_file_dialog.file_selected.connect(_on_image_file_dialog_file_selected)

# --- UI Setup / Generation ---
func _setup_navigation():
	for child in nav_buttons_container.get_children():
		child.queue_free()

	var back_button = Button.new()
	back_button.text = "Back to Main Menu"
	back_button.pressed.connect(_on_back_button_pressed)
	nav_buttons_container.add_child(back_button)

	var top_spacer = Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav_buttons_container.add_child(top_spacer)

	var sorted_keys = asset_types.keys()
	sorted_keys.sort()
	for type_key in sorted_keys:
		var data = asset_types[type_key]
		var nav_button = AssetNavButton.instantiate()
		nav_buttons_container.add_child(nav_button)
		nav_button.set_label(data.label)
		if ICON_PATHS.has(type_key):
			nav_button.set_icon(ICON_PATHS[type_key])
		nav_button.pressed.connect(select_asset_type.bind(type_key))

	var bottom_spacer = Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	nav_buttons_container.add_child(bottom_spacer)
	pass

func _generate_form_for_resource(resource: Resource):
	for i in range(form_tab_container.get_tab_count()): form_tab_container.get_tab_control(0).queue_free()
	if not is_instance_valid(resource): return

	var properties = resource.get_script().get_script_property_list()
	var grouped_properties = _group_properties_by_section(properties)

	for section_name in FORM_SECTIONS.keys():
		if not grouped_properties.has(section_name) or grouped_properties[section_name].is_empty(): continue

		var tab_root_node
		if section_name == "Biography":
			tab_root_node = _create_biography_tab(grouped_properties[section_name], resource)
		else:
			tab_root_node = _create_standard_tab(grouped_properties[section_name], resource)

		form_tab_container.add_child(tab_root_node)
		form_tab_container.set_tab_title(form_tab_container.get_tab_count() - 1, section_name)

func _create_standard_tab(properties: Array, resource: Resource) -> Node:
	var scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var tab_content = VBoxContainer.new()
	tab_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(tab_content)

	for p in properties:
		var field_container = _create_field_row(p, resource)
		tab_content.add_child(field_container)
	return scroll_container

func _create_biography_tab(properties: Array, resource: Resource) -> Node:
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 20)

	# --- Left side (Image) ---
	var image_vbox = VBoxContainer.new()
	image_vbox.custom_minimum_size.x = 256
	image_vbox.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	hbox.add_child(image_vbox)

	var title_label = Label.new()
	title_label.theme_type_variation = &"Title"
	title_label.text = _get_resource_name(resource)
	image_vbox.add_child(title_label)

	var image_panel = PanelContainer.new()
	image_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	image_vbox.add_child(image_panel)

	# Placeholder for when no image is set
	image_placeholder = VBoxContainer.new()
	image_placeholder.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	image_placeholder.alignment = BoxContainer.ALIGNMENT_CENTER
	image_panel.add_child(image_placeholder)
	var placeholder_label = Label.new()
	placeholder_label.text = "No Image"
	placeholder_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var set_image_button = Button.new()
	set_image_button.text = "Set Image"
	set_image_button.pressed.connect(_on_upload_button_pressed)
	image_placeholder.add_child(placeholder_label)
	image_placeholder.add_child(set_image_button)

	# Actual image display
	card_image_rect = TextureRect.new()
	card_image_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	card_image_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	card_image_rect.visible = false
	image_panel.add_child(card_image_rect)

	# Buttons for interaction
	var image_button_hbox = HBoxContainer.new()
	image_vbox.add_child(image_button_hbox)
	var change_image_button = Button.new()
	change_image_button.text = "Change..."
	change_image_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	change_image_button.pressed.connect(_on_upload_button_pressed)
	delete_image_button = Button.new()
	delete_image_button.text = "Delete"
	delete_image_button.pressed.connect(_on_delete_image_pressed)
	image_button_hbox.add_child(change_image_button)
	image_button_hbox.add_child(delete_image_button)

	# --- Right side (Fields) ---
	var fields_scroll = ScrollContainer.new()
	fields_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(fields_scroll)
	var fields_vbox = VBoxContainer.new()
	fields_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fields_scroll.add_child(fields_vbox)

	for p in properties:
		var field_container = _create_field_row(p, resource)
		fields_vbox.add_child(field_container)

	return hbox

func _create_field_row(p: Dictionary, resource: Resource) -> HBoxContainer:
	var field_container = HBoxContainer.new()
	field_container.name = p.name + "Field"
	if PROPERTY_TOOLTIPS.has(p.name): field_container.tooltip_text = PROPERTY_TOOLTIPS[p.name]

	var label = Label.new()
	label.text = p.name.capitalize().replace("_", " ")
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.size_flags_stretch_ratio = 0.35

	var editor = _get_editor_for_property(p, resource)
	if p.name in SHORT_FIELDS:
		editor.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	else:
		editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor.size_flags_stretch_ratio = 0.65

	field_container.add_child(label)
	field_container.add_child(editor)
	return field_container

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
	pass
func _get_resource_name(resource: Resource) -> String:
	if not is_instance_valid(resource): return "Invalid Resource"

	const NAME_PROPERTIES = ["full_name", "location_name", "item_name", "faction_name", "district_name", "name"]
	for prop in NAME_PROPERTIES:
		if prop in resource:
			var value = resource.get(prop)
			if value is String and not value.is_empty(): return value

	return "Unnamed Resource"
	pass
func _update_asset_list():
	for child in asset_list_container.get_children(): child.queue_free()
	if not asset_types.has(current_asset_type): return

	var type_data = asset_types[current_asset_type]
	var list_title = $HSplitContainer/ContentSplitter/AssetListPane/ListLayout/PanelContainer/ListTitle
	list_title.text = type_data.label

	var new_button = Button.new()
	new_button.text = "New %s" % type_data.label.trim_suffix("s")
	new_button.pressed.connect(show_detail_view.bind(null))
	asset_list_container.add_child(new_button)

	for resource in type_data.items:
		var list_item = AssetCard.instantiate()
		asset_list_container.add_child(list_item)
		list_item.set_data(resource)
		list_item.custom_signal.connect(show_detail_view)
	pass
func _group_properties_by_section(properties: Array) -> Dictionary:
	var grouped = {}
	var assigned_properties = []

	for section_name in FORM_SECTIONS:
		grouped[section_name] = []
		var section_fields = FORM_SECTIONS[section_name]
		for p in properties:
			if p.name in section_fields and p.usage & PROPERTY_USAGE_EDITOR:
				grouped[section_name].append(p)
				assigned_properties.append(p.name)

	if not grouped.has("Default"): grouped["Default"] = []

	for p in properties:
		if not p.name in assigned_properties and p.usage & PROPERTY_USAGE_EDITOR:
			grouped["Default"].append(p)

	var final_groups = {}
	for section_name in grouped:
		if not grouped[section_name].is_empty(): final_groups[section_name] = grouped[section_name]
	return final_groups
	pass
func _get_editor_for_property(p: Dictionary, resource: Resource) -> Node:
	var editor
	var current_value = resource.get(p.name)

	var linked_asset_type = ""
	for type_key in asset_types:
		if type_key.to_lower().trim_suffix("s") == p.name.to_lower().replace("_", " "):
			linked_asset_type = type_key
			break

	if not linked_asset_type.is_empty():
		var option_button = OptionButton.new()
		option_button.add_item("[None]", -1)

		var items = asset_types[linked_asset_type].items
		for i in range(items.size()):
			var item_resource = items[i]
			option_button.add_item(_get_resource_name(item_resource), i)
			if item_resource.id == current_value: option_button.select(i + 1)
		editor = option_button
	else:
		match p.type:
			TYPE_STRING:
				if p.hint == PROPERTY_HINT_MULTILINE_TEXT:
					editor = TextEdit.new()
					editor.custom_minimum_size.y = 100
				else: editor = LineEdit.new()
				editor.text = str(current_value) if current_value != null else ""
			TYPE_INT, TYPE_FLOAT:
				if p.hint == PROPERTY_HINT_RANGE:
					var slider = HSlider.new()
					var hint_values = p.hint_string.split(",")
					if hint_values.size() >= 2:
						slider.min_value = float(hint_values[0])
						slider.max_value = float(hint_values[1])
					if hint_values.size() >= 3: slider.step = float(hint_values[2])
					slider.value = current_value or 0
					editor = slider
				else:
					var spinbox = SpinBox.new()
					spinbox.allow_lesser = true
					spinbox.allow_greater = true
					spinbox.value = current_value or 0
					editor = spinbox
			TYPE_BOOL:
				editor = CheckBox.new()
				editor.button_pressed = current_value or false
			TYPE_ARRAY, TYPE_DICTIONARY:
				editor = TextEdit.new()
				editor.custom_minimum_size.y = 100
				editor.text = JSON.stringify(current_value, "'''	'''")
			TYPE_VECTOR2I:
				if p.name == "alignment":
					editor = AlignmentEditor.instantiate()
					editor.set_alignment(current_value)
				else:
					editor = LineEdit.new()
					editor.text = str(current_value)
					editor.editable = false
			_:
				editor = LineEdit.new()
				editor.text = str(current_value)
				editor.editable = false

	editor.name = p.name
	return editor
	pass

# --- UI State & Image Helpers ---
func select_asset_type(type_key: String):
	current_asset_type = type_key
	current_resource = null
	hide_detail_view()
	_update_asset_list()
	pass

func show_detail_view(resource):
	if is_instance_valid(resource): current_resource = resource
	else: current_resource = load(asset_types[current_asset_type].script_path).new()

	_generate_form_for_resource(current_resource)
	_update_image_display()

	detail_placeholder.hide()
	form_view.show()

func hide_detail_view():
	form_view.hide()
	detail_placeholder.show()
	pass

func _update_image_display():
	if not is_instance_valid(card_image_rect): return # Not a character

	var texture = null
	if "image_path" in current_resource and not current_resource.image_path.is_empty():
		texture = _load_texture_from_path(current_resource.image_path)

	card_image_rect.texture = texture
	var has_image = texture != null

	card_image_rect.visible = has_image
	delete_image_button.visible = has_image
	image_placeholder.visible = not has_image

func _load_texture_from_path(path: String) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null

	var file_bytes = FileAccess.get_file_as_bytes(path)
	if file_bytes.is_empty():
		push_error("Could not load image file at path: %s" % path)
		return null

	var image = Image.new()
	var err
	var extension = path.get_extension().to_lower()
	match extension:
		"jpg", "jpeg":
			err = image.load_jpg_from_buffer(file_bytes)
		"png":
			err = image.load_png_from_buffer(file_bytes)
		"webp":
			err = image.load_webp_from_buffer(file_bytes)
		_:
			push_error("Unsupported image format: %s" % extension)
			return null

	if err != OK:
		push_error("Failed to load image data from buffer for file: %s" % path)
		return null

	return ImageTexture.create_from_image(image)
	pass

# --- Signal Handlers ---
func _on_cancel_pressed(): hide_detail_view()
func _on_upload_button_pressed(): image_file_dialog.popup_centered()

func _on_image_file_dialog_file_selected(path: String):
	if is_instance_valid(current_resource) and "image_path" in current_resource:
		current_resource.image_path = path
		_update_image_display()

func _on_delete_image_pressed():
	if is_instance_valid(current_resource) and "image_path" in current_resource:
		current_resource.image_path = ""
		_update_image_display()

func _on_save_pressed():
	if not is_instance_valid(current_resource): return
	var properties = current_resource.get_script().get_script_property_list()

	for i in range(form_tab_container.get_tab_count()):
		var scroll = form_tab_container.get_tab_control(i)
		var tab_content = scroll.get_child(0)

		for field_container in tab_content.get_children():
			if not field_container is HBoxContainer: continue

			var editor = field_container.get_child(1)
			var property_name = editor.name
			var property_info = null
			for p in properties:
				if p.name == property_name:
					property_info = p
					break
			if property_info == null: continue

			var value
			if editor is OptionButton:
				var selected_index = editor.get_selected_id()
				if selected_index > -1:
					var linked_asset_type = ""
					for type_key in asset_types:
						if type_key.to_lower().trim_suffix("s") == property_name.to_lower().replace("_", " "):
							linked_asset_type = type_key
							break
					if not linked_asset_type.is_empty():
						value = asset_types[linked_asset_type].items[selected_index].id
				else: value = ""
			elif editor is GridContainer and property_name == "alignment": value = editor.get_alignment()
			else:
				match property_info.type:
					TYPE_STRING: value = editor.text
					TYPE_INT, TYPE_FLOAT: value = editor.value
					TYPE_BOOL: value = editor.button_pressed
					TYPE_ARRAY, TYPE_DICTIONARY:
						var parse_result = JSON.parse_string(editor.text)
						if parse_result: value = parse_result

			if value != null: current_resource.set(property_name, value)

	var path = current_resource.resource_path
	if path.is_empty():
		var type_label = asset_types[current_asset_type].label.to_lower()
		var resource_name = _get_resource_name(current_resource).to_snake_case()
		if resource_name == "unnamed_resource": resource_name = str(Time.get_unix_time_from_system())
		path = "res://cases/%s_%s.tres" % [type_label.trim_suffix("s"), resource_name]

	var save_error = ResourceSaver.save(current_resource, path, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
	if save_error != OK:
		push_error("Failed to save resource to path: %s" % path)
		return

	_scan_for_resources()
	_update_asset_list()
	hide_detail_view()
	pass
func _on_back_button_pressed():
	get_tree().change_scene_to_packed(main_menu_scene)
	pass
