@tool
extends Resource
class_name DistrictResource

@export var id: String = ""
@export var district_name: String = ""
@export_multiline var description: String = ""
@export var wealth_class: String = "" # e.g., "Opulent", "Working Class"
@export_multiline var atmosphere: String = ""
@export var key_locations: PackedStringArray
@export var population_density: String = "" # e.g., "Dense", "Sparse"
@export var notable_features: PackedStringArray
@export var dominant_faction: String = "" # Should link to a FactionResource.id