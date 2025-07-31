@tool
extends Resource
class_name ItemResource

@export var id: String = ""
@export var item_name: String = ""
@export var image_path: String = ""
@export var item_type: String = "" # e.g., "Weapon", "Document", "Personal Effect"
@export_multiline var description: String = ""
@export_multiline var use: String = ""
@export var is_possible_means: bool = false
@export var is_possible_motive: bool = false
@export var is_possible_opportunity: bool = false
@export var default_location: String = "" # Links to LocationResource.id
@export var default_owner: String = "" # Links to CharacterResource.id
@export_multiline var significance: String = ""
@export_multiline var clue_potential: String = ""
@export var value: String = ""
@export var condition: String = ""
@export_multiline var unique_properties: String = ""