@tool
extends Resource
class_name ClueResource

@export var id: String = ""
@export var is_critical: bool = false
@export var character_implicated: String = "" # Links to CharacterResource.id
@export var is_red_herring: bool = false
@export var red_herring_type: String = "" # e.g., "False Lead", "Misinterpretation"
@export_multiline var mechanism_of_misdirection: String = ""
@export var debunking_clue: String = "" # Links to another ClueResource.id
@export var source: String = "" # e.g., "Witness Testimony", "Forensics"
@export_multiline var summary: String = ""
@export_multiline var discovery_path: String = ""
@export_multiline var presentation_method: String = ""
@export var knowledge_level: String = "" # e.g., "Common", "Expert"
@export var dependencies: PackedStringArray # Other clues needed first
@export_multiline var required_actions: String = ""
@export_multiline var reveals_unlocks: String = ""
@export var associated_item: String = "" # Links to ItemResource.id
@export var associated_location: String = "" # Links to LocationResource.id
@export var associated_character: String = "" # Links to CharacterResource.id