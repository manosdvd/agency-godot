## Walkthrough A6: Adding Locations to a Case

Following the same pattern as with characters, we will now add the ability to define and edit **Locations** within a case. Locations are the scenes where the story unfolds, and this walkthrough will integrate the `LocationResource` into our Case Creator tool.

### 1\. Updating the Case Creator UI

First, we'll add a new editor panel for locations.

1.  **Open the Scene:** Open `scenes/case_creator/case_creator.tscn`.
    
2.  **Create the Location Editor Panel:**
    
    -   In the **Scene** dock, select the `MainEditorPanel` (`VBoxContainer`).
        
    -   Add a new `VBoxContainer` as a child. Rename it `LocationEditor`.
        
    -   Make the `LocationEditor` invisible by default by unchecking its `visible` property in the Inspector.
        
3.  **Build the Location Editor Fields:**
    
    -   Select the `LocationEditor` node.
        
    -   Add the following fields inside it:
        
        -   **Location Name:** `HBoxContainer` > `Label` (Text: `Location Name`), `LineEdit` (Rename: `LocationNameEdit`).
            
        -   **Description:** `HBoxContainer` > `Label` (Text: `Description`), `TextEdit` (Rename: `LocationDescriptionEdit`).
            
4.  **Add a "New Location" Button:**
    
    -   Just like with characters, we'll add the creation button to the main `CaseEditor`.
        
    -   Select the `CaseEditor` `VBoxContainer`.
        
    -   Add a new `Button` at the bottom (you can place it next to the "New Character" button in an HBoxContainer for tidiness, or just below it). Rename it `NewLocationButton` and set its Text to "Add New Location to Case".
        

Your scene tree for the right panel should now accommodate all three editors:

    - ScrollContainer (Right Panel)
      - MainEditorPanel (VBoxContainer)
        - CaseEditor (VBoxContainer)
          - ... (Case Name, Description fields)
          - NewCharacterButton
          - NewLocationButton
        - CharacterEditor (VBoxContainer)
          - ... (Character fields)
        - LocationEditor (VBoxContainer)
          - ... (Location Name, Description fields)
        - HBoxContainer (Buttons)
          - NewCaseButton
          - SaveButton
    

### 2\. Expanding the Case Creator Script

Let's add the logic for creating, editing, and saving locations.

1.  **Open the Script:** Open `agency/scripts/case_creator/case_creator.gd`.
    
2.  **Add New Node References:**
    
    -   Add `@onready` variables for the new location editor UI elements.
        
    
        # agency/scripts/case_creator/case_creator.gd
        # ... (existing UI references)
        # Editor Panels
        @onready var location_editor: VBoxContainer = $HSplitContainer/ScrollContainer/MainEditorPanel/LocationEditor
        
        # Case Editor Fields
        # ...
        @onready var new_location_button: Button = $HSplitContainer/ScrollContainer/MainEditorPanel/CaseEditor/NewLocationButton
        
        # Location Editor Fields
        @onready var location_name_edit: LineEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/LocationEditor/HBoxContainer/LocationNameEdit
        @onready var location_description_edit: TextEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/LocationEditor/HBoxContainer2/LocationDescriptionEdit
        
    
3.  **Update `_ready()`:** Connect the new button's signal.
    
        func _ready() -> void:
            # ... (existing connections)
            new_location_button.pressed.connect(_on_new_location_button_pressed)
            # ...
        
    
4.  **Upgrade `_populate_case_tree()`:** This function will now also read and display the `locations` array from each `CaseResource`.
    
        func _populate_case_tree() -> void:
            # ... (inside the `if resource is CaseResource:` block)
        
                            # --- Characters Category ---
                            # ... (this part is unchanged)
        
                            # --- Locations Category ---
                            var locations_category = case_tree.create_item(case_item)
                            locations_category.set_text(0, "Locations")
                            locations_category.set_selectable(0, false)
                            for i in range(resource.locations.size()):
                                var loc_resource: LocationResource = resource.locations[i]
                                var loc_item = case_tree.create_item(locations_category)
                                loc_item.set_text(0, loc_resource.location_name)
                                # Store metadata to identify this item
                                loc_item.set_metadata(0, {"case_path": resource.resource_path, "index": i, "type": "location"})
        
                            # --- Clues Category (still placeholder) ---
                            var clues_item = case_tree.create_item(case_item)
                            # ... (rest of the function is the same)
        
    
5.  **Upgrade `_on_case_tree_item_selected()`:** Add a case to handle the "location" type.
    
        func _on_case_tree_item_selected() -> void:
            # ... (inside the `elif metadata is Dictionary:` block)
                if ResourceLoader.exists(case_path):
                    current_case_resource = ResourceLoader.load(case_path)
        
                    if type == "character" and index < current_case_resource.characters.size():
                        current_resource = current_case_resource.characters[index]
                        _populate_character_editor(current_resource)
                    elif type == "location" and index < current_case_resource.locations.size():
                        current_resource = current_case_resource.locations[index]
                        _populate_location_editor(current_resource)
        
    
6.  **Implement New Functions:** Add the handler for the new button and the editor populating function.
    
        # --- New Signal Handler ---
        
        func _on_new_location_button_pressed() -> void:
            if not current_case_resource:
                print("No case selected to add a location to.")
                return
        
            var new_loc = load("res://scripts/resources/location_resource.gd").new()
            new_loc.location_name = "New Location"
        
            current_case_resource.locations.append(new_loc)
        
            var error = ResourceSaver.save(current_case_resource)
            if error == OK:
                print("Added new location and saved case.")
                _populate_case_tree()
            else:
                print("Error saving case after adding location.")
        
        # --- New and Updated Helper Functions ---
        
        func _populate_location_editor(resource: LocationResource) -> void:
            location_editor.visible = true
            save_button.visible = true
            location_name_edit.text = resource.location_name
            location_description_edit.text = resource.description
        
        func _clear_editor_panels() -> void:
            case_editor.visible = false
            character_editor.visible = false
            location_editor.visible = false # Add this
            save_button.visible = false
        
            # ... (clear case and character fields)
        
            # Add these
            location_name_edit.clear()
            location_description_edit.clear()
        
            current_resource = null
            current_case_resource = null
        
    
7.  **Upgrade `_on_save_button_pressed()`:** The save function now needs to handle saving location details.
    
        func _on_save_button_pressed() -> void:
            if not current_resource:
                return
        
            if current_resource is CaseResource:
                # ... (unchanged)
            elif current_resource is CharacterResource:
                # ... (unchanged)
            elif current_resource is LocationResource:
                current_resource.location_name = location_name_edit.text
                current_resource.description = location_description_edit.text
        
            # IMPORTANT: We always save the parent case resource
            var error = ResourceSaver.save(current_case_resource)
            # ... (rest of the function is the same)
        
    

### 3\. Test Location Creation

Run the project (**F5**) and navigate to the Case Creator.

1.  **Select a Case:** Click on an existing case like `case_01`.
    
2.  **Add Location:** In the case editor, click "Add New Location to Case". The tree on the left should refresh, showing a "New Location" item under a "Locations" category for that case.
    
3.  **Select Location:** Click on the "New Location" item. The editor on the right should switch to the Location Editor.
    
4.  **Edit and Save:** Give the location a name (e.g., "Alleyway behind the theatre") and a description. Click "Save Current Resource".
    
5.  **Verify:** The location's name should update in the tree. Click away and click back on the location to ensure its data loads correctly.
    

You have now added another critical layer to the Case Creator. The application is becoming a robust tool for defining the key narrative elements of your game. The next step will be to add clues.





