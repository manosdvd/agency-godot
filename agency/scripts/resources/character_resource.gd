# res://scripts/resources/character_resource.gd
extends Resource
class_name CharacterResource

@export var id: String = ""
@export var full_name: String = "New Character"
@export var alias: String = ""
@export var age: int = 30
@export var gender: String = ""
@export var employment: String = ""
@export_multiline var biography: String = ""
@export var image_path: String = ""
@export var faction: String = "" # Links to a FactionResource.id
@export var wealth_class: String = "Middle Class"
@export var district: String = "" # Links to a DistrictResource.id
@export var allies: PackedStringArray # Links to CharacterResource.id
@export var enemies: PackedStringArray # Links to CharacterResource.id
@export var items: PackedStringArray # Links to ItemResource.id
@export var archetype: String = "" # e.g., "Femme Fatale"
@export_multiline var personality: String = ""
@export_multiline var values: String = ""
@export_multiline var flaws_handicaps: String = ""
@export_multiline var quirks: String = ""
@export_multiline var characteristics: String = ""
@export var alignment: Vector2i = Vector2i(1, 1) # For 3x3 grid
@export_multiline var motivations: String = ""
@export_multiline var secrets: String = ""
@export_multiline var vulnerabilities: String = ""
@export var voice_model: String = ""
@export_multiline var dialogue_style: String = ""
@export_multiline var expertise: String = ""
@export_range(0, 100, 1) var honesty: int = 50
@export_range(0, 100, 1) var victim_likelihood: int = 50
@export_range(0, 100, 1) var killer_likelihood: int = 50
@export_multiline var portrayal_notes: String = ""

# Sleuth-specific fields
@export var is_sleuth: bool = false
@export var city: String = ""
@export_multiline var primary_arc: String = ""
