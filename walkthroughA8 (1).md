## Walkthrough A8: Integrating Godot Dialogue Manager

This walkthrough will replace our basic `TextEdit` for dialogue with the powerful **Godot Dialogue Manager** plugin. This will enable us to write complex, branching conversations for our interviews.

### 1\. Installing the Plugin

We'll use Godot's built-in AssetLib to find and install the plugin.

1.  **Open the AssetLib:** In the Godot editor, click the **AssetLib** tab at the top of the main window (next to 2D, 3D, and Script).
    
2.  **Search for the Plugin:** In the search bar, type `Dialogue Manager` and press Enter.
    
3.  **Download:** You should see "Dialogue Manager" by Nathan Hoad. Click on it. On the plugin's page, click the **Download** button.
    
4.  **Install:** Once downloaded, a window will pop up showing the files to be installed. Ensure all files are checked and click the **Install** button. The plugin will be added to your `addons` folder.
    

### 2\. Enabling the Plugin

You must tell Godot to activate the newly installed plugin.

1.  Go to **Project > Project Settings**.
    
2.  Click on the **Plugins** tab.
    
3.  You should see "Dialogue Manager" in the list. On the right side, under the **Status** column, check the **Enable** box.
    
4.  Close the Project Settings window. You will now have a "Dialogue" panel at the bottom of your editor, which is the visual editor we'll be using.
    

### 3\. Updating the `InterviewResource`

Our `InterviewResource` currently holds a `dialogue_script` string. We need to change this to hold a path to a dedicated dialogue file.

1.  **Open the Script:** In the FileSystem, open `scripts/resources/interview_resource.gd`.
    
2.  **Modify the Script:** Change the `dialogue_script` variable to `dialogue_file_path`.
    
        # agency/scripts/resources/interview_resource.gd
        class_name InterviewResource
        extends Resource
        
        @export var character: CharacterResource
        # @export var dialogue_script: String # REMOVE THIS LINE
        @export var dialogue_file_path: String # ADD THIS LINE
        
    

### 4\. Updating the Case Creator UI

We'll replace the large `TextEdit` node with a simpler UI for managing the dialogue file.

1.  **Open the Scene:** Open `scenes/case_creator/case_creator.tscn`.
    
2.  **Modify the `InterviewEditor`:**
    
    -   Select the `InterviewEditor` node.
        
    -   Delete the `VBoxContainer` that holds the "Dialogue Script" label and the `DialogueScriptEdit` `TextEdit` node.
        
    -   In its place, add a new `HBoxContainer`.
        
    -   Inside this `HBoxContainer`, add:
        
        -   A `Label` with its **Text** set to `Dialogue File:`.
            
        -   A `LineEdit` node. Rename it `DialoguePathEdit`. Make it non-editable in the Inspector by unchecking **Editable**.
            
        -   A `Button`. Rename it `EditDialogueButton` and set its **Text** to `Edit...`.
            
        -   A `Button`. Rename it `NewDialogueFileButton` and set its **Text** to `New...`.
            

### 5\. Updating the Case Creator Script

This is the biggest step. We need to change our logic to handle creating, assigning, and opening these new dialogue files instead of just editing text.

1.  **Open the Script:** Open `agency/scripts/case_creator/case_creator.gd`.
    
2.  **Update Node References:** Change the references for the `InterviewEditor`.
    
        # ...
        # Interview Editor Fields
        @onready var interview_subject_selector: OptionButton = $HSplitContainer/ScrollContainer/MainEditorPanel/InterviewEditor/HBoxContainer/InterviewSubjectSelector
        # DELETE the dialogue_script_edit reference
        @onready var dialogue_path_edit: LineEdit = $HSplitContainer/ScrollContainer/MainEditorPanel/InterviewEditor/HBoxContainer2/DialoguePathEdit
        @onready var edit_dialogue_button: Button = $HSplitContainer/ScrollContainer/MainEditorPanel/InterviewEditor/HBoxContainer2/EditDialogueButton
        @onready var new_dialogue_file_button: Button = $HSplitContainer/ScrollContainer/MainEditorPanel/InterviewEditor/HBoxContainer2/NewDialogueFileButton
        
    
3.  **Update `_ready()`:** Connect the new buttons.
    
        func _ready() -> void:
            # ...
            edit_dialogue_button.pressed.connect(_on_edit_dialogue_button_pressed)
            new_dialogue_file_button.pressed.connect(_on_new_dialogue_file_button_pressed)
            # ...
        
    
4.  **Update `_populate_interview_editor()`:**
    
        func _populate_interview_editor(resource: InterviewResource) -> void:
            interview_editor.visible = true
            save_button.visible = true
            dialogue_path_edit.text = resource.dialogue_file_path
            # Disable the "Edit" button if there's no file path
            edit_dialogue_button.disabled = resource.dialogue_file_path.is_empty()
            _populate_interview_subject_selector(resource.character)
        
    
5.  **Update `_on_save_button_pressed()`:** The save logic for interviews is now simpler, as we only need to save the character assignment. The dialogue file is saved separately.
    
        func _on_save_button_pressed() -> void:
            # ...
            elif current_resource is InterviewResource:
                # The dialogue file path is handled by other buttons now.
                # We just need to save the character assignment.
                var selected_id = interview_subject_selector.get_selected_id()
                if selected_id >= 0 and selected_id < current_case_resource.characters.size():
                    current_resource.character = current_case_resource.characters[selected_id]
            # ...
        
    
6.  **Implement New Signal Handlers:**
    
        # --- New Signal Handlers for Dialogue ---
        
        func _on_edit_dialogue_button_pressed() -> void:
            if current_resource is InterviewResource:
                var path = current_resource.dialogue_file_path
                if not path.is_empty() and ResourceLoader.exists(path):
                    # This built-in function tells the Godot editor to open the
                    # specified resource. Because the Dialogue Manager plugin is active,
                    # this will open the special Dialogue Editor, not just a text file.
                    EditorInterface.get_singleton().edit_resource(ResourceLoader.load(path))
        
        func _on_new_dialogue_file_button_pressed() -> void:
            if not (current_case_resource and current_resource is InterviewResource):
                return
        
            # Create a folder to hold the dialogue files for this case if it doesn't exist
            var case_file_name = current_case_resource.resource_path.get_file().get_basename()
            var dialogue_folder_path = "res://cases/dialogue/%s/" % case_file_name
            DirAccess.make_dir_recursive_absolute(dialogue_folder_path)
        
            # Create a unique filename
            var subject_name = "character"
            if current_resource.character:
                subject_name = current_resource.character.character_name.to_lower().replace(" ", "_")
            var new_file_path = dialogue_folder_path.path_join("%s_%s.dialogue" % [subject_name, Time.get_unix_time_from_system()])
        
            # Create a new file with some default content
            var file = FileAccess.open(new_file_path, FileAccess.WRITE)
            file.store_line("~ start")
            file.store_line("Player: I have some questions for you.")
            file.store_line("Character: Go on.")
            file.close()
        
            # Assign the new path to our resource and save the main case
            current_resource.dialogue_file_path = new_file_path
            _on_save_button_pressed() # Save the case to persist the new path
        
            # Update the UI
            dialogue_path_edit.text = new_file_path
            edit_dialogue_button.disabled = false
        
            # Open the new file for editing immediately
            _on_edit_dialogue_button_pressed()
        
    

### 6\. Test the New Dialogue Workflow

1.  **Select an Interview:** In the Case Creator, create or select an interview.
    
2.  **Create Dialogue File:** Click the **New...** button.
    
3.  **The Dialogue Editor Opens:** The Godot editor should automatically switch to the **Dialogue Editor**, which is a visual, node-based graph editor. You will see a `start` node and a `(Empty)` node. This is the primary interface for creating your branching dialogue.
    
4.  **Author the Dialogue:** Use the Dialogue Editor to add dialogue nodes, choices, and conditions. You can right-click in the graph to add new nodes. This is a much more intuitive way to create complex conversations.
    
5.  **Save and Return:** Save your changes in the Dialogue Editor (`Ctrl+S`). You can then return to the Case Creator tab. The file path is saved, and you've successfully authored a complex dialogue tree.
    
6.  **Re-Edit:** Clicking the `Edit...` button in our tool will now always bring you back to this powerful visual editor.
    

This workflow leverages the best of both worlds: our custom **Case Creator** for organizing the case structure, and the specialized **Dialogue Editor** for the complex task of authoring conversations.





