## Walkthrough A4: Building the Case Creator

With the World Builder established, we now turn our attention to the core of the application: the **Case Creator**. This tool will allow you to assemble all the narrative pieces—characters, locations, clues, and interviews—that form a playable case. In this first part, we will build the main UI and implement the functionality to create and edit the main `CaseResource`.

### 1\. Setting Up the Case Creator Scene

We'll structure this scene similarly to the World Builder for a consistent user experience.

1.  **Open the Scene:** In the **FileSystem** dock, navigate to `scenes/case_creator/` and open `case_creator.tscn`.
    
2.  **Delete Placeholder:** If it's still there, delete the placeholder `Label` node.
    
3.  **Add Main Layout:**
    
    -   Select the `CaseCreator` root node.
        
    -   Add an `HSplitContainer` and set its **Anchors Preset** to **Full Rect**.
        
4.  **Add "Back" button:**
    
    -   Select the `CaseCreator` root node.
        
    -   Add a `Button` node, rename it `BackButton`, and set its text to "Back to Main Menu".
        
    -   Position it in the top-left corner (e.g., position 10, 10).
        

### 2\. Building the Left Panel (Case Hierarchy)

The left panel will display a tree view of all cases and their constituent parts.

1.  **Add a `VBoxContainer`:** Select the `HSplitContainer` and add a `VBoxContainer` as its first child.
    
2.  **Add a Label:** Add a `Label` child to the `VBoxContainer`, set its text to `Case Files`, and center it horizontally.
    
3.  **Add a `Tree` node:**
    
    -   Add a `Tree` child to the `VBoxContainer`. Rename it `CaseTree`.
        
    -   In the **Inspector**, under **Layout > Container Sizing**, set the **Vertical** property to **Expand**.
        

### 3\. Building the Right Panel (Editor)

The right panel will contain different editor forms for each type of case resource. We'll start with the main `CaseResource` editor.

1.  **Add a `ScrollContainer`:** Select the `HSplitContainer` and add a `ScrollContainer` as its second child.
    
2.  **Add the Main Editor Panel:**
    
    -   Add a `VBoxContainer` inside the `ScrollContainer`. Rename it `MainEditorPanel`.
        
3.  **Create the Case Editor:**
    
    -   Add another `VBoxContainer` inside `MainEditorPanel`. Rename it `CaseEditor`.
        
    -   Make the `CaseEditor` invisible for now by unchecking its `visible` property in the Inspector.
        
4.  **Build the Case Editor Fields:** Inside the `CaseEditor`, create the following:
    
    -   **Case Name:** `HBoxContainer` > `Label` (Text: `Case Name`), `LineEdit` (Rename: `CaseNameEdit`).
        
    -   **Case Description:** `HBoxContainer` > `Label` (Text: `Description`), `TextEdit` (Rename: `CaseDescriptionEdit`).
        
5.  **Add Control Buttons:**
    
    -   At the bottom of the `MainEditorPanel` (as a direct child, not inside `CaseEditor`), add an `HBoxContainer`.
        
    -   Inside this `HBoxContainer`, add two buttons:
        
        -   `NewCaseButton` (Text: "New Case")
            
        -   `SaveButton` (Text: "Save Current Resource")
            

Your scene tree for the right panel should look like this:

    - ScrollContainer (Right Panel)
      - MainEditorPanel (VBoxContainer)
        - CaseEditor (VBoxContainer)
          - HBoxContainer (Name)
            - Label
            - CaseNameEdit
          - HBoxContainer (Description)
            - Label
            - CaseDescriptionEdit
        - HBoxContainer (Buttons)
          - NewCaseButton
          - SaveButton
    

### 4\. Scripting the Case Creator

Now, let's add the initial logic.

1.  **Attach a Script:** Select the `CaseCreator` root node and attach a new script. Save it as `agency/scripts/case_creator/case_creator.gd`.
    
2.  **Edit the Script:** Replace the default template with the code below. This script sets up the basic functionality for loading, displaying, creating, and saving `CaseResource` files.
    
        # agency/scripts/case_creator/case_creator.gd
        extends Control
        
        # --- UI Node References ---
        @onready var case_tree: Tree = $HSplitContainer/VBoxContainer/CaseTree
        @onready var back_button: Button = $BackButton
        @onready var new_case_button: Button = $HSplitContainer/ScrollContainer/MainEditorPanel/HBoxContainer/NewCaseButton
        @onready var save_button: Button = $HSplitContainer/ScrollContainer/MainEditorPanel/HBoxContainer/SaveButton
        
        # Editor Panels
        @onready var case_editor: VBoxContainer = $HSplitContainer/ScrollContainer/MainEditorPanel/CaseEditor
        
        # Case Editor Fields
        @onready var case_name_edit: LineEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/CaseEditor/HBoxContainer/CaseNameEdit
        @onready var case_description_edit: TextEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/CaseEditor/HBoxContainer2/CaseDescriptionEdit
        
        # --- Constants and Variables ---
        const CASES_DATA_PATH = "res://cases/"
        var main_menu_scene = preload("res://scenes/main_ui/main.tscn")
        var current_resource: Resource = null
        
        func _ready() -> void:
            # --- Connect Signals ---
            back_button.pressed.connect(_on_back_button_pressed)
            case_tree.item_selected.connect(_on_case_tree_item_selected)
            new_case_button.pressed.connect(_on_new_case_button_pressed)
            save_button.pressed.connect(_on_save_button_pressed)
        
            # --- Initial Setup ---
            _populate_case_tree()
            _clear_editor_panels()
        
        # --- Signal Handlers ---
        
        func _on_back_button_pressed() -> void:
            get_tree().change_scene_to_packed(main_menu_scene)
        
        func _on_new_case_button_pressed() -> void:
            var new_case = load("res://scripts/resources/case_resource.gd").new()
            var new_filename = "case_%s.tres" % Time.get_unix_time_from_system()
            new_case.resource_path = CASES_DATA_PATH.path_join(new_filename)
            new_case.case_name = "New Case"
        
            # Save it immediately so it exists on disk
            var error = ResourceSaver.save(new_case)
            if error == OK:
                # Now reload the tree and select the new case
                _populate_case_tree()
                # (Code to find and select the new item will be added later)
            else:
                print("Error creating new case file.")
        
        func _on_save_button_pressed() -> void:
            if not current_resource:
                return
        
            # For now, we only handle saving the CaseResource itself
            if current_resource is CaseResource:
                current_resource.case_name = case_name_edit.text
                current_resource.description = case_description_edit.text
        
                var error = ResourceSaver.save(current_resource)
                if error == OK:
                    print("Case saved successfully: ", current_resource.resource_path)
                    # Refresh tree to reflect potential name change
                    _populate_case_tree()
                else:
                    print("Error saving case.")
        
        func _on_case_tree_item_selected() -> void:
            _clear_editor_panels()
            var selected_item = case_tree.get_selected()
            if not selected_item:
                current_resource = null
                return
        
            # Check if the selected item is a top-level case
            var file_path = selected_item.get_metadata(0)
            if file_path and ResourceLoader.exists(file_path):
                var resource = ResourceLoader.load(file_path)
                if resource is CaseResource:
                    current_resource = resource
                    _populate_case_editor(resource)
        
        # --- Helper Functions ---
        
        func _populate_case_tree() -> void:
            case_tree.clear()
            var root = case_tree.create_item()
            case_tree.hide_root = true
        
            var dir = DirAccess.open(CASES_DATA_PATH)
            if dir:
                dir.list_dir_begin()
                var file_name = dir.get_next()
                while file_name != "":
                    if not dir.current_is_dir() and file_name.ends_with(".tres"):
                        var full_path = CASES_DATA_PATH.path_join(file_name)
                        var resource = ResourceLoader.load(full_path)
        
                        if resource is CaseResource:
                            # Create a top-level item for the case
                            var case_item = case_tree.create_item(root)
                            case_item.set_text(0, resource.case_name)
                            case_item.set_metadata(0, full_path)
        
                            # Create placeholder categories under the case
                            var characters_item = case_tree.create_item(case_item)
                            characters_item.set_text(0, "Characters")
                            characters_item.set_selectable(0, false)
        
                            var locations_item = case_tree.create_item(case_item)
                            locations_item.set_text(0, "Locations")
                            locations_item.set_selectable(0, false)
        
                            var clues_item = case_tree.create_item(case_item)
                            clues_item.set_text(0, "Clues")
                            clues_item.set_selectable(0, false)
        
                    file_name = dir.get_next()
            else:
                print("Could not open directory: ", CASES_DATA_PATH)
        
        func _populate_case_editor(resource: CaseResource) -> void:
            case_editor.visible = true
            save_button.visible = true
            case_name_edit.text = resource.case_name
            case_description_edit.text = resource.description
        
        func _clear_editor_panels() -> void:
            case_editor.visible = false
            save_button.visible = false
            case_name_edit.clear()
            case_description_edit.clear()
            current_resource = null
        
    

### 5\. Test the Case Creator

Press **F5** and navigate to the Case Creator from the main menu.

1.  **Existing Case:** You should see `case_01.tres` listed on the left. Click on it. The "Case Editor" should appear on the right, populated with the case's name and description.
    
2.  **Edit and Save:** Change the description and click "Save Current Resource". The changes will be saved to the `.tres` file.
    
3.  **Create New Case:** Click "New Case". A new case file will be created in your `cases` folder, and the tree on the left will refresh to show it.
    
4.  **Select New Case:** Click on your newly created case. The editor will appear, and you can give it a proper name and description and save it.
    

You now have the foundation for the Case Creator. It can manage high-level `CaseResource` files. In the next walkthrough, we will expand it by adding an editor for `CharacterResource` and linking characters to the case.





