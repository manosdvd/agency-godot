## Walkthrough A1: The Main Hub

Welcome to the updated walkthrough for **Agency**. This guide will walk you through creating a central navigation hub for the application, connecting it to the various tools like the World Builder.

### 1. The Main Scene: Hub of the App

We'll configure the `main.tscn` to act as our main menu.

1.  **Open the Main Scene:** In Godot's **FileSystem** dock, open `scenes/main_ui/main.tscn`.
2.  **Structure the Scene:** Ensure the scene has a `Control` node as its root, named `Main`. The structure should be a `CenterContainer` with a `VBoxContainer` inside, which will hold your title `Label` and the navigation `Button`s.

    Your scene tree should look like this:
    - `Main` (Control)
      - `CenterContainer`
        - `VBoxContainer`
          - `TitleLabel` (Label)
          - `WorldBuilderButton` (Button)
          - `CaseCreatorButton` (Button)
          - `ValidatorButton` (Button)
          - `QuitButton` (Button)

3.  **Apply the Theme:** Select the `Main` node and assign your `main_theme.tres` to its **Theme** property in the Inspector.

### 2. Create Placeholder Scenes

To make the main menu functional, we need the scenes it will navigate to.

1.  **Create `world_builder.tscn`:**
    -   Create a new scene with a `Control` node as the root, named `WorldBuilder`.
    -   Save it as `scenes/world_builder/world_builder.tscn`.
    -   Add a `Label` to it with the text "World Builder" to identify it.

2.  **Create `case_creator.tscn` and `validator.tscn`:**
    -   Repeat the process for `case_creator.tscn` and `validator.tscn`, saving them in their respective `scenes` subdirectories.

### 3. Scripting the Main Menu

Attach a GDScript to the `Main` node, named `main.gd`, and save it in `scripts/main_ui/`. This script will handle scene transitions.

    # agency/scripts/main_ui/main.gd
    extends Control

    # Preload scenes for efficient switching
    var world_builder_scene = preload("res://scenes/world_builder/world_builder.tscn")
    var case_creator_scene = preload("res://scenes/case_creator/case_creator.tscn")
    var validator_scene = preload("res://scenes/validator/validator.tscn")

    func _ready():
        # Connect button signals to their respective functions
        $CenterContainer/VBoxContainer/WorldBuilderButton.pressed.connect(
            _on_world_builder_button_pressed
        )
        $CenterContainer/VBoxContainer/CaseCreatorButton.pressed.connect(
            _on_case_creator_button_pressed
        )
        $CenterContainer/VBoxContainer/ValidatorButton.pressed.connect(
            _on_validator_button_pressed
        )
        $CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

    func _on_world_builder_button_pressed():
        get_tree().change_scene_to_packed(world_builder_scene)

    func _on_case_creator_button_pressed():
        get_tree().change_scene_to_packed(case_creator_scene)

    func _on_validator_button_pressed():
        get_tree().change_scene_to_packed(validator_scene)

    func _on_quit_button_pressed():
        get_tree().quit()

**Test your setup:** Run the project (F5). The main menu should appear, and the buttons should navigate to the correct placeholder scenes. The "Quit" button should close the application.