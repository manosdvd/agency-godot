# alignment_editor.gd
extends GridContainer

signal alignment_changed(new_alignment)

var current_alignment: Vector2i = Vector2i(1, 1)

func _ready():
	for y in range(3):
		for x in range(3):
			var button = Button.new()
			button.toggle_mode = true
			button.pressed.connect(_on_button_pressed.bind(x, y))
			add_child(button)
	update_buttons()

func set_alignment(alignment: Vector2i):
	current_alignment = alignment
	update_buttons()

func get_alignment() -> Vector2i:
	return current_alignment

func _on_button_pressed(x: int, y: int):
	current_alignment = Vector2i(x, y)
	update_buttons()
	emit_signal("alignment_changed", current_alignment)

func update_buttons():
	for i in range(get_child_count()):
		var button = get_child(i)
		var button_x = i % 3
		var button_y = int(i / 3)
		button.button_pressed = (Vector2i(button_x, button_y) == current_alignment)
