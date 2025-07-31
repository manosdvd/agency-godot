## Walkthrough A2: Building the World Builder

With our main hub in place, it's time to build the first major tool: the **World Builder**. This interface will allow a creator to define, edit, and save the fundamental components of a game world, specifically **Districts** and **Factions**, as outlined in the blueprint.

### 1\. Setting Up the World Builder Scene

First, let's open the placeholder scene we created and set up a professional-looking layout.

1.  **Open the Scene:** In the **FileSystem** dock, navigate to `scenes/world_builder/` and open `world_builder.tscn`.
    
2.  **Delete Placeholder:** Delete the placeholder `Label` node.
    
3.  **Add Main Layout Container:** We'll use an `HSplitContainer` to create two main panels: one on the left for a list of world assets, and one on the right for editing the selected asset.
    
    -   Select the `WorldBuilder` root node.
        
    -   Add a child node: `HSplitContainer`.
        
    -   In the **Inspector**, go to **Layout > Anchors Preset** and select **Full Rect**. This will make it fill the screen.
        
4.  **Add a "Back" button:** We need a way to get back to the main menu.
    
    -   Select the `WorldBuilder` root node.
        
    -   Add a `Button` node. Rename it `BackButton`.
        
    -   In the Inspector, set its **Text** to "Back to Main Menu".
        
    -   In the **Layout** panel, set its **Anchors Preset** to **Top Left**. You may need to adjust its position slightly by changing its `position` properties so it doesn't overlap with the split container. A position of (10, 10) should work well.
        

### 2\. Building the Left Panel (Resource List)

The left panel will list all the world-building resources we can edit (Districts, Factions).

1.  **Add a `VBoxContainer`:** This will hold a label and our list.
    
    -   Select the `HSplitContainer`.
        
    -   Add a `VBoxContainer` as its first child. Godot will automatically place it in the left panel.
        
    -   In the **Inspector**, go to **Layout > Container Sizing** and enable **Expand** for the **Vertical** property.
        
2.  **Add a Label:**
    
    -   Select the `VBoxContainer`.
        
    -   Add a `Label` child.
        
    -   Set its **Text** to `World Resources`.
        
    -   Set **Horizontal Alignment** to `Center`.
        
3.  **Add a `Tree` node:** A `Tree` is perfect for displaying hierarchical data, like factions within a district, though we'll start simple.
    
    -   Select the `VBoxContainer`.
        
    -   Add a `Tree` child node. Rename it `ResourceTree`.
        
    -   In the **Inspector**, under **Layout > Container Sizing**, set the **Vertical** property to **Expand**. This makes the tree fill the available vertical space.
        

### 3\. Building the Right Panel (Editor)

The right panel is where the details of a selected resource will be displayed and edited.

1.  **Add a `ScrollContainer`:** This ensures that if our editor form gets long, the user can scroll.
    
    -   Select the `HSplitContainer`.
        
    -   Add a `ScrollContainer` as its second child. It will go into the right panel.
        
    -   In the **Inspector**, enable **Follow Focus**. This is a great usability feature that automatically scrolls to the focused UI element.
        
2.  **Add a `VBoxContainer`:** This will stack our editor fields.
    
    -   Select the `ScrollContainer`.
        
    -   Add a `VBoxContainer` child. Rename it `EditorPanel`.
        
    -   In the **Inspector**, under **Layout > Container Sizing**, set the **Horizontal** property to **Expand**.
        
3.  **Create the Editor Fields:** We'll add labeled input fields for the properties of a `DistrictResource`.
    
    -   For each field below, you will:
        
        1.  Add an `HBoxContainer` to the `EditorPanel`.
            
        2.  Add a `Label` to the `HBoxContainer`.
            
        3.  Add the corresponding input control (`LineEdit` or `TextEdit`) to the `HBoxContainer`.
            
    -   **Name Field:**
        
        -   `HBoxContainer`
            
            -   `Label` (Text: `Name`)
                
            -   `LineEdit` (Rename: `NameEdit`)
                
    -   **Description Field:**
        
        -   `HBoxContainer`
            
            -   `Label` (Text: `Description`)
                
            -   `TextEdit` (Rename: `DescriptionEdit`, set a minimum height in **Layout > Custom Minimum Size**)
                
    -   Add **Save** and **New** buttons at the bottom.
        
        -   Select the `EditorPanel`.
            
        -   Add an `HBoxContainer`.
            
        -   Add two `Button` children to it: `SaveButton` (Text: "Save Resource") and `NewButton` (Text: "New District").
            

Your final scene tree for `world_builder.tscn` should look something like this:

    - WorldBuilder (Control)
      - HSplitContainer
        - VBoxContainer (Left Panel)
          - Label
          - ResourceTree
        - ScrollContainer (Right Panel)
          - EditorPanel (VBoxContainer)
            - HBoxContainer (Name)
              - Label
              - NameEdit (LineEdit)
            - HBoxContainer (Description)
              - Label
              - DescriptionEdit (TextEdit)
            - HBoxContainer (Buttons)
              - SaveButton
              - NewButton
      - BackButton
    

### 4\. Scripting the World Builder

Now, let's add the logic.

1.  **Create Folders:** We need a place to save our world data. Use the Gemini CLI or Godot's FileSystem dock to create a new top-level folder called `worlds`.
    
        mkdir -p agency/worlds/default
        
    
2.  **Attach a Script:** Select the `WorldBuilder` root node and attach a new script. Save it as `agency/scripts/world_builder/world_builder.gd`.
    
3.  **Edit the Script:** Replace the default template with the code below. Read the comments carefully to understand what each part does.
    
        # agency/scripts/world_builder/world_builder.gd
        extends Control
        
        # --- UI Node References ---
        @onready var resource_tree: Tree = $HSplitContainer/VBoxContainer/ResourceTree
        @onready var name_edit: LineEdit = $HSplitContainer/ScrollContainer/EditorPanel/HBoxContainer/NameEdit
        @onready var description_edit: TextEdit = $HSplitContainer/ScrollContainer/EditorPanel/HBoxContainer2/DescriptionEdit
        @onready var save_button: Button = $HSplitContainer/ScrollContainer/EditorPanel/HBoxContainer3/SaveButton
        @onready var new_button: Button = $HSplitContainer/ScrollContainer/EditorPanel/HBoxContainer3/NewButton
        @onready var back_button: Button = $BackButton
        
        # --- Constants and Variables ---
        const WORLD_DATA_PATH = "res://worlds/default/"
        var main_menu_scene = preload("res://scenes/main_ui/main.tscn")
        var current_resource: Resource = null
        
        
        func _ready() -> void:
            # --- Connect Signals ---
            back_button.pressed.connect(_on_back_button_pressed)
            resource_tree.item_selected.connect(_on_resource_tree_item_selected)
            save_button.pressed.connect(_on_save_button_pressed)
            new_button.pressed.connect(_on_new_button_pressed)
        
            # --- Initial Setup ---
            _populate_resource_tree()
            _clear_editor_panel()
            # Disable the editor until a resource is selected or created
            $HSplitContainer/ScrollContainer.visible = false
        
        
        # --- Signal Handlers ---
        
        func _on_back_button_pressed() -> void:
            get_tree().change_scene_to_packed(main_menu_scene)
        
        func _on_resource_tree_item_selected() -> void:
            _clear_editor_panel()
        
            var selected_item: TreeItem = resource_tree.get_selected()
            if not selected_item:
                current_resource = null
                return
        
            var file_path = selected_item.get_metadata(0)
            if file_path and ResourceLoader.exists(file_path):
                current_resource = ResourceLoader.load(file_path)
                _populate_editor_panel(current_resource)
                $HSplitContainer/ScrollContainer.visible = true
        
        func _on_save_button_pressed() -> void:
            if not current_resource:
                return # Can't save if nothing is loaded
        
            # Update the resource properties from the UI fields
            current_resource.name = name_edit.text
            current_resource.description = description_edit.text
        
            # Save the resource back to its file
            var error = ResourceSaver.save(current_resource)
            if error != OK:
                print("Error saving resource: ", error)
            else:
                print("Resource saved successfully to: ", current_resource.resource_path)
                # Refresh the tree to show any name changes
                _populate_resource_tree()
        
        func _on_new_button_pressed() -> void:
            # Create a new instance of a DistrictResource
            var new_district = load("res://scripts/resources/district_resource.gd").new()
        
            # Give it a temporary name and path
            var new_filename = "district_%s.tres" % Time.get_unix_time_from_system()
            new_district.resource_path = WORLD_DATA_PATH.path_join(new_filename)
            new_district.name = "New District"
        
            # Set it as the current resource and populate the editor
            current_resource = new_district
            _populate_editor_panel(current_resource)
            $HSplitContainer/ScrollContainer.visible = true
            name_edit.grab_focus() # Put the cursor in the name field
        
        
        # --- Helper Functions ---
        
        func _populate_resource_tree() -> void:
            resource_tree.clear()
            var root = resource_tree.create_item()
            resource_tree.hide_root = true
        
            var districts_item = resource_tree.create_item(root)
            districts_item.set_text(0, "Districts")
            districts_item.set_selectable(0, false) # Make the category non-selectable
        
            # Use DirAccess to find all .tres files in our world data path
            var dir = DirAccess.open(WORLD_DATA_PATH)
            if dir:
                dir.list_dir_begin()
                var file_name = dir.get_next()
                while file_name != "":
                    if not dir.current_is_dir() and file_name.ends_with(".tres"):
                        var full_path = WORLD_DATA_PATH.path_join(file_name)
                        var resource = ResourceLoader.load(full_path)
        
                        # Check if it's a DistrictResource before adding
                        if resource is DistrictResource:
                            var tree_item = resource_tree.create_item(districts_item)
                            tree_item.set_text(0, resource.name)
                            tree_item.set_metadata(0, full_path) # Store the path in the item
        
                    file_name = dir.get_next()
            else:
                print("Could not open directory: ", WORLD_DATA_PATH)
        
        func _populate_editor_panel(resource: Resource) -> void:
            if resource is DistrictResource:
                name_edit.text = resource.name
                description_edit.text = resource.description
            else:
                _clear_editor_panel()
        
        func _clear_editor_panel() -> void:
            name_edit.clear()
            description_edit.clear()
            $HSplitContainer/ScrollContainer.visible = false
            current_resource = null
        
        
    

### 5\. Test the World Builder

Press **F5** to run the project. From the main menu, click "World Builder".

1.  **Create a New District:** Click the "New District" button. The editor panel on the right should appear.
    
2.  **Edit and Save:** Give your new district a name (e.g., "Downtown Core") and a description. Click "Save Resource". You should see a success message in the Godot **Output** log. The new district should now appear in the list on the left.
    
3.  **Select and Edit:** Click the new district in the list. Its details should load back into the editor panel. Change the description and click "Save Resource" again.
    
4.  **Navigate:** Click the "Back to Main Menu" button to ensure it returns you to the main hub.
    

You now have a functional, albeit basic, World Builder! You can create, edit, and save `DistrictResource` files. In the next walkthrough, we will expand this tool to also handle `FactionResource`s and establish relationships between them.





