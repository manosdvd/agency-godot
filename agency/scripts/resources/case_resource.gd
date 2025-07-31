@tool
extends Resource
class_name CaseResource

# --- Case Meta ---
@export var victim: String = "" # Links to CharacterResource.id
@export var culprit: String = "" # Links to CharacterResource.id
@export var crime_scene: String = "" # Links to LocationResource.id
@export var murder_weapon: String = "" # Links to ItemResource.id
@export var weapon_is_hidden: bool = false
@export var means_clue: String = "" # Links to ClueResource.id
@export var motive_clue: String = "" # Links to ClueResource.id
@export var opportunity_clue: String = "" # Links to ClueResource.id
@export var red_herring_clues: PackedStringArray # Links to ClueResource.id
@export var narrative_viewpoint: String = "" # e.g., "First Person (Sleuth)"
@export var narrative_tense: String = "" # e.g., "Past Tense"
@export_multiline var core_mystery_solution: String = ""
@export_multiline var ultimate_reveal_scene: String = ""
@export_multiline var opening_monologue: String = ""
@export_multiline var successful_denouement: String = ""
@export_multiline var failed_denouement: String = ""

# --- Case Data ---
# Dictionary where key is Character.id and value is an Array of InterviewResources
@export var interviews: Dictionary = {}
# Dictionary where key is Location.id and value is a PackedStringArray of Clue.id's
@export var location_clues: Dictionary = {}
# Array of all ClueResources associated with this case
@export var clues: Array[ClueResource]