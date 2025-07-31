## Walkthrough A5: Adding Characters to a Case

Now that we have the foundation for the Case Creator, we'll populate it with content. The first and most important element of any case is its cast of characters. This walkthrough will guide you through creating an editor for `CharacterResource` and integrating these characters into the selected case.

Unlike world data, case elements like characters, locations, and clues are _embedded_ within the main `CaseResource` file. They do not get saved as separate `.tres` files.

### 1\. Updating the Case Creator UI

We need to add a new editor panel for characters and a way to trigger its creation.

1.  **Open the Scene:** Open `scenes/case_creator/case_creator.tscn`.
    
2.  **Create the Character Editor Panel:**
    
    -   In the **Scene** dock, select the `MainEditorPanel` (`VBoxContainer`).
        
    -   Add a new `VBoxContainer` as a child. Rename it `CharacterEditor`.
        
    -   Like before, make the `CharacterEditor` invisible by default by unchecking its `visible` property in the Inspector.
        
3.  **Build the Character Editor Fields:**
    
    -   Select the `CharacterEditor` node.
        
    -   Add the following fields inside it:
        
        -   **Character Name:** `HBoxContainer` > `Label` (Text: `Character Name`), `LineEdit` (Rename: `CharacterNameEdit`).
            
        -   **Description:** `HBoxContainer` > `Label` (Text: `Description`), `TextEdit` (Rename: `CharacterDescriptionEdit`).
            
        -   **Home Faction:** `HBoxContainer` > `Label` (Text: `Home Faction`), `OptionButton` (Rename: `FactionSelector`). This will be our dropdown for selecting a faction from the world data.
            
4.  **Add a "New Character" Button:**
    
    -   We need a way to add a new character _to the currently selected case_. A good place for this is within the `CaseEditor` itself.
        
    -   Select the `CaseEditor` `VBoxContainer`.
        
    -   Add a new `Button` at the bottom. Rename it `NewCharacterButton` and set its Text to "Add New Character to Case".
        

Your scene tree for the right panel should now be structured like this:

    - ScrollContainer (Right Panel)
      - MainEditorPanel (VBoxContainer)
        - CaseEditor (VBoxContainer)
          - ... (Case Name, Description fields)
          - NewCharacterButton
        - CharacterEditor (VBoxContainer)
          - ... (Character Name, Description, Faction fields)
        - HBoxContainer (Buttons)
          - NewCaseButton
          - SaveButton
    

### 2\. Expanding the Case Creator Script

Let's implement the logic to handle this new resource type.

1.  **Open the Script:** Open `agency/scripts/case_creator/case_creator.gd`.
    
2.  **Add New Node References and Variables:**
    
    -   Add `@onready` variables for the new UI elements.
        
    -   Add a variable to keep track of the currently selected case, even when we are editing one of its sub-resources.
        
    
        # agency/scripts/case_creator/case_creator.gd
        # ... (existing UI references)
        # Editor Panels
        @onready var character_editor: VBoxContainer = $HSplitContainer/ScrollContainer/MainEditorPanel/CharacterEditor
        
        # Case Editor Fields
        # ...
        @onready var new_character_button: Button = $HSplitContainer/ScrollContainer/MainEditorPanel/CaseEditor/NewCharacterButton
        
        # Character Editor Fields
        @onready var character_name_edit: LineEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/CharacterEditor/HBoxContainer/CharacterNameEdit
        @onready var character_description_edit: TextEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/CharacterEditor/HBoxContainer2/CharacterDescriptionEdit
        @onready var faction_selector: OptionButton = $HSplitContainer/ScrollContainer/MainEditorPanel/CharacterEditor/HBoxContainer3/FactionSelector
        
        # --- Constants and Variables ---
        const WORLD_DATA_PATH = "res://worlds/default/"
        # ... (existing variables)
        var current_case_resource: CaseResource = null # To track the parent case
        
    
3.  **Update `_ready()`:** Connect the new button's signal.
    
        func _ready() -> void:
            # ... (existing connections)
            new_character_button.pressed.connect(_on_new_character_button_pressed)
            # ...
        
    
4.  **Upgrade `_populate_case_tree()`:** This function will now read the `characters` array from each `CaseResource` and list them.
    
        func _populate_case_tree() -> void:
            # ... (keep the start of the function)
                        if resource is CaseResource:
                            var case_item = case_tree.create_item(root)
                            case_item.set_text(0, resource.case_name)
                            case_item.set_metadata(0, resource.resource_path)
        
                            # --- Characters Category ---
                            var characters_category = case_tree.create_item(case_item)
                            characters_category.set_text(0, "Characters")
                            characters_category.set_selectable(0, false)
                            # Now, iterate through the actual characters in the case
                            for i in range(resource.characters.size()):
                                var char_resource: CharacterResource = resource.characters[i]
                                var char_item = case_tree.create_item(characters_category)
                                char_item.set_text(0, char_resource.character_name)
                                # Store the PARENT case path and the INDEX of the character
                                char_item.set_metadata(0, {"case_path": resource.resource_path, "index": i, "type": "character"})
        
                            # --- Other Categories (still placeholders) ---
                            var locations_item = case_tree.create_item(case_item)
                            # ... (rest of the function is the same)
        
    
5.  **Upgrade `_on_case_tree_item_selected()`:** This now needs to handle selections for both cases and characters.
    
        func _on_case_tree_item_selected() -> void:
            _clear_editor_panels()
            var selected_item = case_tree.get_selected()
            if not selected_item:
                current_resource = null
                current_case_resource = null
                return
        
            var metadata = selected_item.get_metadata(0)
            if not metadata:
                return
        
            # If metadata is just a string, it's a CaseResource path
            if metadata is String:
                if ResourceLoader.exists(metadata):
                    var resource = ResourceLoader.load(metadata)
                    if resource is CaseResource:
                        current_resource = resource
                        current_case_resource = resource
                        _populate_case_editor(resource)
            # If metadata is a Dictionary, it's a sub-resource
            elif metadata is Dictionary:
                var case_path = metadata.get("case_path")
                var index = metadata.get("index")
                var type = metadata.get("type")
        
                if ResourceLoader.exists(case_path):
                    current_case_resource = ResourceLoader.load(case_path)
                    if type == "character" and index < current_case_resource.characters.size():
                        current_resource = current_case_resource.characters[index]
                        _populate_character_editor(current_resource)
        
    
6.  **Implement New Functions:** Add handlers for the new button and editors.
    
        # --- New Signal Handler ---
        
        func _on_new_character_button_pressed() -> void:
            if not current_case_resource:
                print("No case selected to add a character to.")
                return
        
            var new_char = load("res://scripts/resources/character_resource.gd").new()
            new_char.character_name = "New Character"
        
            # Add the new character resource to the array in the case
            current_case_resource.characters.append(new_char)
        
            # Save the main case file, which now contains the new character data
            var error = ResourceSaver.save(current_case_resource)
            if error == OK:
                print("Added new character and saved case.")
                # Refresh the tree to show the new character
                _populate_case_tree()
            else:
                print("Error saving case after adding character.")
        
        # --- New and Updated Helper Functions ---
        
        func _populate_character_editor(resource: CharacterResource) -> void:
            character_editor.visible = true
            save_button.visible = true
            character_name_edit.text = resource.character_name
            character_description_edit.text = resource.description
            _populate_faction_selector(resource.home_faction)
        
        func _populate_faction_selector(current_selection: FactionResource = null) -> void:
            faction_selector.clear()
        
            var dir = DirAccess.open(WORLD_DATA_PATH)
            if dir:
                dir.list_dir_begin()
                var file_name = dir.get_next()
                while file_name != "":
                    if not dir.current_is_dir() and file_name.ends_with(".tres"):
                        var full_path = WORLD_DATA_PATH.path_join(file_name)
                        var resource = ResourceLoader.load(full_path)
        
                        if resource is FactionResource:
                            var index = faction_selector.get_item_count()
                            faction_selector.add_item(resource.name, index)
                            faction_selector.set_item_metadata(index, full_path)
                            if current_selection and current_selection.resource_path == full_path:
                                faction_selector.select(index)
                    file_name = dir.get_next()
        
        func _clear_editor_panels() -> void:
            case_editor.visible = false
            character_editor.visible = false # Add this
            save_button.visible = false
        
            case_name_edit.clear()
            case_description_edit.clear()
        
            # Add these
            character_name_edit.clear()
            character_description_edit.clear()
            faction_selector.clear()
        
            current_resource = null
            current_case_resource = null # Add this
        
    
7.  **Upgrade `_on_save_button_pressed()`:** The save button must now handle saving character details back to the main case file.
    
        func _on_save_button_pressed() -> void:
            if not current_resource:
                return
        
            if current_resource is CaseResource:
                current_resource.case_name = case_name_edit.text
                current_resource.description = case_description_edit.text
            elif current_resource is CharacterResource:
                current_resource.character_name = character_name_edit.text
                current_resource.description = character_description_edit.text
        
                var selected_id = faction_selector.get_selected_id()
                if selected_id >= 0:
                    var faction_path = faction_selector.get_item_metadata(selected_id)
                    current_resource.home_faction = ResourceLoader.load(faction_path)
                else:
                    current_resource.home_faction = null
        
            # IMPORTANT: We always save the parent case resource
            var error = ResourceSaver.save(current_case_resource)
            if error == OK:
                print("Resource saved successfully in case: ", current_case_resource.resource_path)
                _populate_case_tree() # Refresh to show name changes
            else:
                print("Error saving case.")
        
    

### 3\. Test Character Creation

Run the project (**F5**) and go to the Case Creator.

1.  **Select a Case:** Click on `case_01`. The case editor appears.
    
2.  **Add Character:** Click the "Add New Character to Case" button. The tree on the left should refresh, and a "New Character" item should appear under the "Characters" category for `case_01`.
    
3.  **Select Character:** Click on the "New Character" item in the tree. The editor on the right should switch to the Character Editor.
    
4.  **Edit and Save:** Give the character a name and description. If you created any factions in the World Builder, select one from the dropdown. Click "Save Current Resource".
    
5.  **Verify:** The character's name should update in the tree. Click away and click back on the character to ensure the data (including the selected faction) loads correctly.
    

You have now successfully implemented the first layer of nested resources in the Case Creator. The same pattern will be used to add locations, clues, and other narrative elements.





