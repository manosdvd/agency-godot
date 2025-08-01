# asset_list_item.gd
extends PanelContainer

signal custom_signal(resource)

@onready var name_label = $VBoxContainer/NameLabel
@onready var description_label = $VBoxContainer/DescriptionLabel

var current_resource: Resource

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

func _get_resource_description(resource: Resource) -> String:
	if not is_instance_valid(resource):
		return ""
	if resource.has("biography"):
		var value = resource.get("biography")
		if value is String:
			return value
	return ""

func set_data(resource: Resource):
	current_resource = resource
	name_label.text = _get_resource_name(resource)
	description_label.text = _get_resource_description(resource)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		emit_signal("custom_signal", current_resource)
