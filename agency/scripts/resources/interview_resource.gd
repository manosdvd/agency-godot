@tool
# Represents a single Q&A block in an interview with a character.
extends Resource
class_name InterviewResource

@export_multiline var question: String = ""
@export_multiline var answer: String = ""
@export var is_lie: bool = false
@export var debunking_clue: String = "" # Links to ClueResource.id
@export var is_clue: bool = false
@export var clue_revealed: String = "" # Links to ClueResource.id
@export var provides_item: String = "" # Links to ItemResource.id