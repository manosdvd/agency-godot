# faction_resource.gd
extends Resource
class_name FactionResource

@export var id: String = ""
@export var faction_name: String = ""
@export var archetype: String = "" # e.g., "Syndicate", "Corporation"
@export_multiline var description: String = ""
@export_multiline var ideology: String = ""
@export var headquarters: String = "" # Links to a LocationResource.id
@export_multiline var resources: String = ""
@export var image_path: String = ""
@export var ally_factions: PackedStringArray # Links to FactionResource.id
@export var enemy_factions: PackedStringArray # Links to FactionResource.id
@export var members: PackedStringArray # Links to CharacterResource.id
@export var influence: String = "" # e.g., "City-wide", "Neighborhood"
@export var public_perception: String = ""
