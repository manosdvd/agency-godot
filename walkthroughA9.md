## Walkthrough A9: The Case Validator

With the World Builder and Case Creator complete, we can now generate a wealth of data. But is that data valid? Does every clue have a location? Does every interview have a dialogue file? The **Validator** is a crucial tool that will programmatically check a `CaseResource` for completeness and logical consistency, flagging errors and warnings for the creator to fix.

### 1\. Setting Up the Validator Scene

We'll create a simple interface to select a case, run the validation, and see the results.

1.  **Open the Scene:** In the **FileSystem** dock, navigate to `scenes/validator/` and open `validator.tscn`.
    
2.  **Delete Placeholder:** Remove the placeholder `Label` node if it exists.
    
3.  **Add Main Layout:**
    
    -   Select the `Validator` root node.
        
    -   Add a `VBoxContainer` and set its **Layout > Anchors Preset** to **Full Rect**. To give it some padding, go to the **Theme Overrides > Constants** section in the Inspector and set a `separation` of `10` and then find the **Layout > Container Sizing** and set a `margin` of `10` on all sides.
        
4.  **Add UI Elements:** Add the following nodes as children of the `VBoxContainer`:
    
    -   A `Button`. Rename it `BackButton` and set its text to "Back to Main Menu".
        
    -   An `HBoxContainer` with the following children:
        
        -   A `Label` with its text set to "Case to Validate:".
            
        -   An `OptionButton` (dropdown menu). Rename it `CaseSelector`. Set its **Size Flags > Horizontal** to **Expand Fill**.
            
    -   A `Button`. Rename it `ValidateButton` and set its text to "Run Validation".
        
    -   A `RichTextLabel`. Rename it `ResultsOutput`. This will display our formatted results. Set its **Size Flags > Vertical** to **Expand Fill** so it takes up the remaining space. Set **BB Code > Enabled** to `true`.
        

Your scene tree should look like this:

    - Validator (Control)
      - VBoxContainer
        - BackButton
        - HBoxContainer
          - Label
          - CaseSelector
        - ValidateButton
        - ResultsOutput
    

### 2\. Scripting the Validator

The script will handle loading cases, running a series of checks, and formatting the output.

1.  **Attach a Script:** Select the `Validator` root node and attach a new script. Save it as `agency/scripts/validator/validator.gd`.
    
2.  **Edit the Script:** Replace the default template with the code below.
    
        # agency/scripts/validator/validator.gd
        extends Control
        
        # --- UI Node References ---
        @onready var back_button: Button = $VBoxContainer/BackButton
        @onready var case_selector: OptionButton = $VBoxContainer/HBoxContainer/CaseSelector
        @onready var validate_button: Button = $VBoxContainer/ValidateButton
        @onready var results_output: RichTextLabel = $VBoxContainer/ResultsOutput
        
        # --- Constants and Variables ---
        const CASES_DATA_PATH = "res://cases/"
        var main_menu_scene = preload("res://scenes/main_ui/main.tscn")
        
        func _ready() -> void:
            # --- Connect Signals ---
            back_button.pressed.connect(_on_back_button_pressed)
            validate_button.pressed.connect(_on_validate_button_pressed)
        
            # --- Initial Setup ---
            _populate_case_selector()
            results_output.clear()
        
        # --- Signal Handlers ---
        
        func _on_back_button_pressed() -> void:
            get_tree().change_scene_to_packed(main_menu_scene)
        
        func _on_validate_button_pressed() -> void:
            results_output.clear()
        
            var selected_id = case_selector.get_selected_id()
            if selected_id < 0:
                results_output.text = "Please select a case to validate."
                return
        
            var case_path = case_selector.get_item_metadata(selected_id)
            if not ResourceLoader.exists(case_path):
                results_output.text = "Error: Could not find case file at %s" % case_path
                return
        
            var case_resource: CaseResource = ResourceLoader.load(case_path)
            _run_validation(case_resource)
        
        # --- Helper Functions ---
        
        func _populate_case_selector() -> void:
            case_selector.clear()
            var dir = DirAccess.open(CASES_DATA_PATH)
            if dir:
                dir.list_dir_begin()
                var file_name = dir.get_next()
                while file_name != "":
                    if not dir.current_is_dir() and file_name.ends_with(".tres"):
                        var full_path = CASES_DATA_PATH.path_join(file_name)
                        var index = case_selector.get_item_count()
                        case_selector.add_item(file_name, index)
                        case_selector.set_item_metadata(index, full_path)
                    file_name = dir.get_next()
        
        func _run_validation(case: CaseResource) -> void:
            var errors: Array[String] = []
            var warnings: Array[String] = []
        
            results_output.append_text("[b]Validating Case: %s[/b]\n\n" % case.case_name)
        
            # --- Run Checks ---
            if case.characters.is_empty():
                warnings.append("Case has no characters.")
            if case.locations.is_empty():
                warnings.append("Case has no locations.")
            if case.clues.is_empty():
                warnings.append("Case has no clues.")
            if case.interviews.is_empty():
                warnings.append("Case has no interviews.")
        
            for char in case.characters:
                if char.home_faction == null:
                    warnings.append("Character '[i]%s[/i]' has no home faction assigned." % char.character_name)
        
            for clue in case.clues:
                if clue.location_found == null:
                    errors.append("Clue '[i]%s[/i]' is not assigned to a location." % clue.clue_name)
        
            for interview in case.interviews:
                if interview.character == null:
                    errors.append("An interview is not assigned to a character.")
                if interview.dialogue_file_path.is_empty():
                    var subject = "Unassigned Character"
                    if interview.character:
                        subject = interview.character.character_name
                    errors.append("Interview with '[i]%s[/i]' is missing its dialogue file." % subject)
                elif not ResourceLoader.exists(interview.dialogue_file_path):
                    errors.append("Dialogue file not found for interview with '[i]%s[/i]' at path: %s" % [interview.character.character_name, interview.dialogue_file_path])
        
            # --- Display Results ---
            if errors.is_empty() and warnings.is_empty():
                results_output.append_text("[color=green]Validation Complete: No issues found![/color]")
                return
        
            if not errors.is_empty():
                results_output.append_text("[color=red][b]Errors:[/b][/color]\n")
                for error in errors:
                    results_output.append_text(" - %s\n" % error)
                results_output.append_text("\n")
        
            if not warnings.is_empty():
                results_output.append_text("[color=yellow][b]Warnings:[/b][/color]\n")
                for warning in warnings:
                    results_output.append_text(" - %s\n" % warning)
        
    

### 3\. Test the Validator

1.  **Run the Project:** Press **F5** and navigate to the **Validator** from the main menu.
    
2.  **Select a Case:** The dropdown should be populated with your case files (e.g., `case_01.tres`). Select one.
    
3.  **Run Validation:** Click the "Run Validation" button. The `RichTextLabel` will fill with a report. You will likely see some warnings for missing elements if you haven't fully fleshed out your cases.
    
4.  **Introduce an Error:** Go back to the **Case Creator**. Select a clue and, in its editor, set its "Location Found" to nothing (you may need to temporarily add a blank option to your `_populate_clue_location_selector` function to do this, or simply delete the line assigning it in the `.tres` file manually). Save the case.
    
5.  **Re-validate:** Return to the Validator and run it again on the same case. You should now see a red error message telling you exactly which clue is unassigned.
    

You have now built all the core creator-facing tools for **Agency**. You have a robust pipeline for creating worlds, authoring cases, and verifying that the data is ready for a player. The final stage is to build the player-facing UI and game loop.





