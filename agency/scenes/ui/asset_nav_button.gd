# asset_nav_button.gd
extends Button

@onready var label = $VBoxContainer/Label
@onready var icon_texture = $VBoxContainer/TextureRect

func set_label(p_text: String):
	label.text = p_text

func set_icon(p_icon_path: String):
	icon_texture.texture = load(p_icon_path)
