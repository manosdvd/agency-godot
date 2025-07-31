## Walkthrough A7: Adding Clues to a Case

With characters and locations in place, it's time to introduce the evidence. This walkthrough will add the final core narrative element to the Case Creator: **Clues**. We will create an editor for `ClueResource` and establish a direct link between a clue and the location where it is discovered.

### 1\. Updating the Case Creator UI

We'll add a new editor for clues and integrate its creation into the location workflow.

1.  **Open the Scene:** Open `scenes/case_creator/case_creator.tscn`.
    
2.  **Create the Clue Editor Panel:**
    
    -   In the **Scene** dock, select the `MainEditorPanel` (`VBoxContainer`).
        
    -   Add a new `VBoxContainer` as a child. Rename it `ClueEditor`.
        
    -   Make the `ClueEditor` invisible by default.
        
3.  **Build the Clue Editor Fields:**
    
    -   Select the `ClueEditor` node.
        
    -   Add the following fields inside it:
        
        -   **Clue Name:** `HBoxContainer` > `Label` (Text: `Clue Name`), `LineEdit` (Rename: `ClueNameEdit`).
            
        -   **Description:** `HBoxContainer` > `Label` (Text: `Description`), `TextEdit` (Rename: `ClueDescriptionEdit`).
            
        -   **Location Found:** `HBoxContainer` > `Label` (Text: `Location Found`), `OptionButton` (Rename: `ClueLocationSelector`). This dropdown will show locations from the current case.
            
4.  **Add a "New Clue" Button:**
    
    -   A clue is intrinsically linked to where it's found. Therefore, the most intuitive place to create a clue is from within the **Location Editor**.
        
    -   Select the `LocationEditor` `VBoxContainer`.
        
    -   Add a new `Button` at the bottom. Rename it `NewClueButton` and set its Text to "Add New Clue at this Location".
        

Your scene tree for the right panel will now include the `ClueEditor`:

    - ScrollContainer (Right Panel)
      - MainEditorPanel (VBoxContainer)
        - CaseEditor (...)
        - CharacterEditor (...)
        - LocationEditor (VBoxContainer)
          - ... (Location fields)
          - NewClueButton
        - ClueEditor (VBoxContainer)
          - ... (Clue fields)
        - HBoxContainer (Buttons)
          - ...
    

### 2\. Expanding the Case Creator Script

Time to wire up the logic for our new resource type.

1.  **Open the Script:** Open `agency/scripts/case_creator/case_creator.gd`.
    
2.  **Add New Node References:**
    
    -   Add `@onready` variables for the clue editor UI elements.
        
    
        # agency/scripts/case_creator/case_creator.gd
        # ...
        # Editor Panels
        @onready var clue_editor: VBoxContainer = $HSplitContainer/ScrollContainer/MainEditorPanel/ClueEditor
        
        # Location Editor Fields
        @onready var new_clue_button: Button = $HSplitContainer/ScrollContainer/MainEditorPanel/LocationEditor/NewClueButton
        
        # Clue Editor Fields
        @onready var clue_name_edit: LineEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/ClueEditor/HBoxContainer/ClueNameEdit
        @onready var clue_description_edit: TextEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/ClueEditor/HBoxContainer2/ClueDescriptionEdit
        @onready var clue_location_selector: OptionButton = $HSplitContainer/ScrollContainer/MainEditorPanel/ClueEditor/HBoxContainer3/ClueLocationSelector
        
    
3.  **Update `_ready()`:** Connect the new button's signal.
    
        func _ready() -> void:
            # ... (existing connections)
            new_clue_button.pressed.connect(_on_new_clue_button_pressed)
            # ...
        
    
4.  **Upgrade `_populate_case_tree()`:** This function will now read and display the `clues` array.
    
        func _populate_case_tree() -> void:
            # ... (inside the `if resource is CaseResource:` block)
        
                            # --- Locations Category ---
                            # ... (this part is unchanged)
        
                            # --- Clues Category ---
                            var clues_category = case_tree.create_item(case_item)
                            clues_category.set_text(0, "Clues")
                            clues_category.set_selectable(0, false)
                            for i in range(resource.clues.size()):
                                var clue_resource: ClueResource = resource.clues[i]
                                var clue_item = case_tree.create_item(clues_category)
                                clue_item.set_text(0, clue_resource.clue_name)
                                # Store metadata to identify this item
                                clue_item.set_metadata(0, {"case_path": resource.resource_path, "index": i, "type": "clue"})
        
    
5.  **Upgrade `_on_case_tree_item_selected()`:** Add a case to handle the "clue" type.
    
        func _on_case_tree_item_selected() -> void:
            # ... (inside the `elif metadata is Dictionary:` block)
                    # ...
                    elif type == "location" and index < current_case_resource.locations.size():
                        current_resource = current_case_resource.locations[index]
                        _populate_location_editor(current_resource)
                    elif type == "clue" and index < current_case_resource.clues.size():
                        current_resource = current_case_resource.clues[index]
                        _populate_clue_editor(current_resource)
        
    
6.  **Implement New Functions:**
    
        # --- New Signal Handler ---
        
        func _on_new_clue_button_pressed() -> void:
            # This button is in the Location Editor, so a location must be selected.
            if not (current_case_resource and current_resource is LocationResource):
                print("No location selected to add a clue to.")
                return
        
            var new_clue = load("res://scripts/resources/clue_resource.gd").new()
            new_clue.clue_name = "New Clue"
            # Automatically assign the currently open location
            new_clue.location_found = current_resource
        
            current_case_resource.clues.append(new_clue)
        
            var error = ResourceSaver.save(current_case_resource)
            if error == OK:
                print("Added new clue and saved case.")
                _populate_case_tree()
            else:
                print("Error saving case after adding clue.")
        
        # --- New and Updated Helper Functions ---
        
        func _populate_clue_editor(resource: ClueResource) -> void:
            clue_editor.visible = true
            save_button.visible = true
            clue_name_edit.text = resource.clue_name
            clue_description_edit.text = resource.description
            _populate_clue_location_selector(resource.location_found)
        
        func _populate_clue_location_selector(current_location: LocationResource) -> void:
            clue_location_selector.clear()
            if not current_case_resource:
                return
        
            # Populate the dropdown with locations from the current case
            for i in range(current_case_resource.locations.size()):
                var location: LocationResource = current_case_resource.locations[i]
                clue_location_selector.add_item(location.location_name, i)
        
                # If this is the currently assigned location, select it
                if current_location and current_location == location:
                    clue_location_selector.select(i)
        
        func _clear_editor_panels() -> void:
            # ...
            location_editor.visible = false
            clue_editor.visible = false # Add this
            save_button.visible = false
        
            # ... (clear other fields)
        
            # Add these
            clue_name_edit.clear()
            clue_description_edit.clear()
            clue_location_selector.clear()
        
            current_resource = null
            current_case_resource = null
        
    
7.  **Upgrade `_on_save_button_pressed()`:** The save function must now handle clue details.
    
        func _on_save_button_pressed() -> void:
            # ... (inside the function)
            elif current_resource is LocationResource:
                # ... (unchanged)
            elif current_resource is ClueResource:
                current_resource.clue_name = clue_name_edit.text
                current_resource.description = clue_description_edit.text
        
                # Get the selected location from the dropdown
                var selected_id = clue_location_selector.get_selected_id()
                if selected_id >= 0 and selected_id < current_case_resource.locations.size():
                    current_resource.location_found = current_case_resource.locations[selected_id]
        
            # IMPORTANT: We always save the parent case resource
            var error = ResourceSaver.save(current_case_resource)
            # ... (rest of the function is the same)
        
    

### 3\. Test Clue Creation

Run the project (**F5**) and go to the Case Creator.

1.  **Select a Location:** Select a case, then select one of its locations from the tree. The Location Editor will appear.
    
2.  **Add Clue:** Click the "Add New Clue at this Location" button. The tree will refresh, and a "New Clue" item will appear under that case's "Clues" category.
    
3.  **Select Clue:** Click on the new clue in the tree. The Clue Editor will appear.
    
4.  **Verify Location:** The "Location Found" dropdown should be automatically set to the location you were just viewing.
    
5.  **Edit and Save:** Give the clue a name (e.g., "Discarded Lighter") and description. You can even change its location using the dropdown. Click "Save Current Resource".
    
6.  **Verify:** The clue's name should update in the tree. Click away and back to ensure all data loads correctly.
    

The Case Creator is now a powerful tool, capable of defining the who, where, and what of your detective stories. The final step in content creation is defining the _how_—the interviews and dialogue that drive the investigation forward.





