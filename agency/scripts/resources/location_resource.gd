# res://scripts/resources/location_resource.gd
extends Resource
class_name LocationResource

@export var id: String = ""
@export var location_name: String = "New Location"
@export var location_type: String = "" # e.g., "Bar", "Apartment"
@export_multiline var description: String = ""
@export var district: String = "" # Links to a DistrictResource.id
@export var owning_faction: String = "" # Links to a FactionResource.id
@export_range(0, 100, 1) var danger_level: int = 50
@export var population: String = ""
@export var image_path: String = "" # Path to texture
@export var key_characters: PackedStringArray # Links to CharacterResource.id
@export var associated_items: PackedStringArray # Links to ItemResource.id
@export_multiline var accessibility: String = ""
@export var is_hidden: bool = false
@export var clues_present: PackedStringArray # Links to ClueResource.id
@export_multiline var internal_logic_notes: String = ""
