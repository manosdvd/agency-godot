## Walkthrough A3: Factions and Relationships

In this walkthrough, we'll enhance the **World Builder** to manage `FactionResource` files alongside the `DistrictResource` files we've already implemented. This involves creating a dynamic editor panel that changes based on the type of resource selected and adding the ability to link factions to districts.

### 1\. Updating the World Builder UI

We need to adapt our UI to handle two different types of resources. We will create two separate "editor" containers and show/hide them as needed.

1.  **Open the Scene:** Open `scenes/world_builder/world_builder.tscn`.
    
2.  **Reorganize the Editor Panel:**
    
    -   In the **Scene** dock, find the `EditorPanel` (`VBoxContainer`) inside the `ScrollContainer`. Rename it to `DistrictEditor`. This will now exclusively handle district editing.
        
    -   Select the `ScrollContainer` and add a _new_ `VBoxContainer`. Rename this one to `FactionEditor`. This will be for editing factions.
        
    -   For now, select the new `FactionEditor` node and in the **Inspector**, go to the **Visibility** section and set its **Visible** property to `false`. We will control its visibility through code.
        
3.  **Build the Faction Editor Fields:**
    
    -   Select the `FactionEditor` node.
        
    -   Just like we did for the `DistrictEditor`, add the following fields inside the `FactionEditor` `VBoxContainer`:
        
        -   **Name Field:** `HBoxContainer` > `Label` (Text: `Name`), `LineEdit` (Rename: `FactionNameEdit`)
            
        -   **Description Field:** `HBoxContainer` > `Label` (Text: `Description`), `TextEdit` (Rename: `FactionDescriptionEdit`)
            
        -   **Controlling District Field:** This is for linking the faction to a district.
            
            -   `HBoxContainer` > `Label` (Text: `Controlling District`)
                
            -   `OptionButton` (Rename: `DistrictSelector`) An `OptionButton` is a dropdown menu.
                
4.  **Adjust the "New" Buttons:**
    
    -   Our single "New District" button is no longer sufficient.
        
    -   In the `DistrictEditor`, find the `HBoxContainer` holding the `SaveButton` and `NewButton`.
        
    -   Rename `NewButton` to `NewDistrictButton`.
        
    -   Now, select the `FactionEditor` and add a similar `HBoxContainer` at the bottom.
        
    -   Inside this new `HBoxContainer`, add a `Button`. Rename it `NewFactionButton` and set its **Text** to "New Faction".
        
    -   We can share the `SaveButton`. Move the `SaveButton` from the `DistrictEditor`'s `HBoxContainer` so it's a direct child of the `ScrollContainer`'s main `VBoxContainer` (the one that holds both editors). You might need to create a new parent `VBoxContainer` inside the `ScrollContainer` to hold the two editors and the save button cleanly. A better structure is:
        
            - ScrollContainer
              - MainEditorPanel (VBoxContainer)
                - DistrictEditor (VBoxContainer)
                  - ... (fields)
                  - HBoxContainer
                    - NewDistrictButton
                - FactionEditor (VBoxContainer)
                  - ... (fields)
                  - HBoxContainer
                    - NewFactionButton
                - SaveButton
            
        
    
    This simplifies saving, as we only need one save button.
    

Your new scene tree should look roughly like this:

    - WorldBuilder (Control)
      - HSplitContainer
        - ... (Left Panel is unchanged)
        - ScrollContainer (Right Panel)
          - MainEditorPanel (VBoxContainer)
            - DistrictEditor (VBoxContainer)
              - HBoxContainer (Name)
              - HBoxContainer (Description)
              - HBoxContainer
                - NewDistrictButton
            - FactionEditor (VBoxContainer)
              - HBoxContainer (Name)
              - HBoxContainer (Description)
              - HBoxContainer (District)
              - HBoxContainer
                - NewFactionButton
            - SaveButton
      - BackButton
    

### 2\. Upgrading the World Builder Script

Now we'll modify the script to manage both resource types and their relationship.

1.  **Open the Script:** Open `agency/scripts/world_builder/world_builder.gd`.
    
2.  **Add New Node References:** Add `@onready` variables for the new UI elements at the top of your script.
    
        # --- UI Node References ---
        # ... (existing references)
        @onready var district_editor: VBoxContainer = $HSplitContainer/ScrollContainer/MainEditorPanel/DistrictEditor
        @onready var faction_editor: VBoxContainer = $HSplitContainer/ScrollContainer/MainEditorPanel/FactionEditor
        
        # District Fields
        @onready var name_edit: LineEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/DistrictEditor/HBoxContainer/NameEdit
        @onready var description_edit: TextEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/DistrictEditor/HBoxContainer2/DescriptionEdit
        @onready var new_district_button: Button = $HSplitContainer/ScrollContainer/MainEditorPanel/DistrictEditor/HBoxContainer3/NewDistrictButton
        
        # Faction Fields
        @onready var faction_name_edit: LineEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/FactionEditor/HBoxContainer/FactionNameEdit
        @onready var faction_description_edit: TextEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/FactionEditor/HBoxContainer2/FactionDescriptionEdit
        @onready var district_selector: OptionButton = $HSplitContainer/ScrollContainer/MainEditorPanel/FactionEditor/HBoxContainer3/DistrictSelector
        @onready var new_faction_button: Button = $HSplitContainer/ScrollContainer/MainEditorPanel/FactionEditor/HBoxContainer4/NewFactionButton
        
        # Shared Button
        @onready var save_button: Button = $HSplitContainer/ScrollContainer/MainEditorPanel/SaveButton
        
    
    _Note: Your node paths might be slightly different depending on your exact scene structure. Use the editor's "Copy Node Path" feature if needed._
    
3.  **Update `_ready()`:** Connect the signals for the new buttons.
    
        func _ready() -> void:
            # ... (existing connections)
            # Old new_button connection can be removed or updated
            new_district_button.pressed.connect(_on_new_district_button_pressed)
            new_faction_button.pressed.connect(_on_new_faction_button_pressed)
        
            # --- Initial Setup ---
            _populate_resource_tree()
            _clear_editor_panel()
        
    
4.  **Modify `_populate_resource_tree()`:** This function needs to find and categorize both Districts and Factions.
    
        func _populate_resource_tree() -> void:
            resource_tree.clear()
            var root = resource_tree.create_item()
            resource_tree.hide_root = true
        
            # Create categories
            var districts_item = resource_tree.create_item(root)
            districts_item.set_text(0, "Districts")
            districts_item.set_selectable(0, false)
        
            var factions_item = resource_tree.create_item(root)
            factions_item.set_text(0, "Factions")
            factions_item.set_selectable(0, false)
        
            # Use DirAccess to find all .tres files
            var dir = DirAccess.open(WORLD_DATA_PATH)
            if dir:
                dir.list_dir_begin()
                var file_name = dir.get_next()
                while file_name != "":
                    if not dir.current_is_dir() and file_name.ends_with(".tres"):
                        var full_path = WORLD_DATA_PATH.path_join(file_name)
                        var resource = ResourceLoader.load(full_path)
        
                        var parent_node = null
                        if resource is DistrictResource:
                            parent_node = districts_item
                        elif resource is FactionResource:
                            parent_node = factions_item
        
                        if parent_node:
                            var tree_item = resource_tree.create_item(parent_node)
                            tree_item.set_text(0, resource.name)
                            tree_item.set_metadata(0, full_path)
        
                    file_name = dir.get_next()
            else:
                print("Could not open directory: ", WORLD_DATA_PATH)
        
    
5.  **Modify `_populate_editor_panel()`:** This function is now a controller that shows the correct editor.
    
        func _populate_editor_panel(resource: Resource) -> void:
            _clear_editor_panel() # Hide everything first
        
            if resource is DistrictResource:
                district_editor.visible = true
                name_edit.text = resource.name
                description_edit.text = resource.description
            elif resource is FactionResource:
                faction_editor.visible = true
                faction_name_edit.text = resource.name
                faction_description_edit.text = resource.description
                _populate_district_selector(resource.controlling_district)
        
            save_button.visible = true
        
    
6.  **Modify `_on_save_button_pressed()`:** This now needs to know which resource type it's saving.
    
        func _on_save_button_pressed() -> void:
            if not current_resource:
                return
        
            if current_resource is DistrictResource:
                current_resource.name = name_edit.text
                current_resource.description = description_edit.text
            elif current_resource is FactionResource:
                current_resource.name = faction_name_edit.text
                current_resource.description = faction_description_edit.text
        
                var selected_id = district_selector.get_selected_id()
                if selected_id >= 0:
                    var district_path = district_selector.get_item_metadata(selected_id)
                    current_resource.controlling_district = ResourceLoader.load(district_path)
        
            var error = ResourceSaver.save(current_resource)
            if error == OK:
                print("Resource saved successfully: ", current_resource.resource_path)
                _populate_resource_tree()
            else:
                print("Error saving resource: ", error)
        
    
7.  **Implement New Functions:** We need handlers for the new buttons and a helper to populate our dropdown.
    
        # --- New Signal Handlers ---
        
        func _on_new_district_button_pressed() -> void:
            var new_district = load("res://scripts/resources/district_resource.gd").new()
            var new_filename = "district_%s.tres" % Time.get_unix_time_from_system()
            new_district.resource_path = WORLD_DATA_PATH.path_join(new_filename)
            new_district.name = "New District"
        
            current_resource = new_district
            _populate_editor_panel(current_resource)
            name_edit.grab_focus()
        
        func _on_new_faction_button_pressed() -> void:
            var new_faction = load("res://scripts/resources/faction_resource.gd").new()
            var new_filename = "faction_%s.tres" % Time.get_unix_time_from_system()
            new_faction.resource_path = WORLD_DATA_PATH.path_join(new_filename)
            new_faction.name = "New Faction"
        
            current_resource = new_faction
            _populate_editor_panel(current_resource)
            faction_name_edit.grab_focus()
        
        # --- New Helper Functions ---
        
        func _populate_district_selector(current_selection: DistrictResource = null) -> void:
            district_selector.clear()
        
            var dir = DirAccess.open(WORLD_DATA_PATH)
            if dir:
                dir.list_dir_begin()
                var file_name = dir.get_next()
                while file_name != "":
                    if not dir.current_is_dir() and file_name.ends_with(".tres"):
                        var full_path = WORLD_DATA_PATH.path_join(file_name)
                        var resource = ResourceLoader.load(full_path)
        
                        if resource is DistrictResource:
                            var index = district_selector.get_item_count()
                            district_selector.add_item(resource.name, index)
                            district_selector.set_item_metadata(index, full_path)
                            # If this is the currently selected district, set it in the dropdown
                            if current_selection and current_selection.resource_path == full_path:
                                district_selector.select(index)
                    file_name = dir.get_next()
        
        func _clear_editor_panel() -> void:
            # Hide both editors and the save button
            district_editor.visible = false
            faction_editor.visible = false
            save_button.visible = false
        
            # Clear fields
            name_edit.clear()
            description_edit.clear()
            faction_name_edit.clear()
            faction_description_edit.clear()
            district_selector.clear()
        
            current_resource = null
        
    
    _Note: We've replaced the old `_on_new_button_pressed` and updated `_clear_editor_panel`._
    

### 3\. Test the Expanded World Builder

Run the project (**F5**). Go to the World Builder.

1.  **Check Categories:** You should now see "Districts" and "Factions" categories on the left.
    
2.  **Create a District:** Create a district as before. It should appear under the "Districts" category.
    
3.  **Create a Faction:** Click "New Faction". The editor on the right should change to the faction editor.
    
4.  **Assign a District:** The "Controlling District" dropdown should contain the district you just created. Select it.
    
5.  **Save and Verify:** Give the faction a name and description, then click "Save Resource". It should appear under the "Factions" category.
    
6.  **Reload:** Click on the faction again. The correct editor should appear, and the "Controlling District" dropdown should still have the correct district selected.
    

You have now significantly upgraded the World Builder. It acts as a proper database editor for the core components of your world, even handling relationships between them.





