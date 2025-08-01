## Walkthrough A1: The Main Hub

Welcome to the new walkthrough series for **Agency**. In this first part, we'll create the main "hub" of our application. This scene will be the first thing that loads and will allow us to navigate to the different tools we're going to build (World Builder, Case Creator) and, eventually, to the game itself.

### 1\. Re-evaluating the Main Scene

Your current `main.tscn` is likely set up for the Case Creator. We're going to repurpose it to be our main menu.

1.  **Open Godot:** Launch the Godot editor and open your `agency` project.
    
2.  **Open the Main Scene:** In the **FileSystem** dock (usually on the left), double-click `scenes/main_ui/main.tscn` to open it.
    
3.  **Clear the Scene (If Necessary):** If you have any UI elements in this scene from the previous walkthroughs, you can delete them. We want a blank slate. In the **Scene** dock, select any child nodes of your root `Main` node and press the `Delete` key. Make sure the root node itself, named `Main`, is a `Control` node. If it isn't, right-click it, select "Change Type," and choose `Control`.
    

### 2\. Setting Up the Main Menu Layout

We'll create a simple, clean main menu with a title and buttons to access the different parts of the application.

1.  **Add a Center Container:** This will keep our menu vertically and horizontally centered.
    
    -   Select the `Main` root node.
        
    -   Click the `+` button to add a child node.
        
    -   Search for and add a `CenterContainer`.
        
    -   In the **Inspector** for the `CenterContainer`, go to the **Layout** section, click **Anchors Preset**, and select **Full Rect**. This makes it fill the entire screen.
        
2.  **Add a Vertical Box Container:** This will stack our title and buttons neatly.
    
    -   Select the `CenterContainer`.
        
    -   Add a child node: `VBoxContainer`.
        
3.  **Add the Title:**
    
    -   Select the `VBoxContainer`.
        
    -   Add a child node: `Label`.
        
    -   In the **Inspector** for the `Label`, set the following properties:
        
        -   **Text:** `AGENCY`
            
        -   **Horizontal Alignment:** `Center`
            
    -   To make the title larger, we'll use the theme you already created. Go to the **Inspector**, find the **Theme Overrides** section, expand **Fonts**, and drag your `PoiretOne-Regular.ttf` from the `assets` folder into the `Font` property. Then, expand **Font Sizes** and set the `Font Size` to something large, like `96`.
        
4.  **Add the Buttons:**
    
    -   Select the `VBoxContainer`.
        
    -   Add a child node: `Button`. Rename it to `WorldBuilderButton`.
        
    -   In the **Inspector**, set its **Text** to `World Builder`.
        
    -   Select the `VBoxContainer` again and add another `Button`. Rename it to `CaseCreatorButton`. Set its **Text** to `Case Creator`.
        
    -   Add a third `Button`. Rename it to `ValidatorButton`. Set its **Text** to `Validator`.
        
    -   Add a final `Button`. Rename it to `QuitButton`. Set its **Text** to `Quit`.
        
5.  **Apply the Theme:**
    
    -   Select the `Main` root node.
        
    -   In the **Inspector**, find the **Theme** property.
        
    -   Drag your `themes/main_theme.tres` file from the **FileSystem** dock into this property. This should style all the child nodes, including your new buttons.
        

Your scene tree should look like this:

    - Main (Control)
      - CenterContainer
        - VBoxContainer
          - Label
          - WorldBuilderButton
          - CaseCreatorButton
          - ValidatorButton
          - QuitButton
    

Press **F5** to run the project. You should see your centered main menu.

### 3\. Creating Placeholder Scenes for the Editors

Before we can script the buttons, we need scenes to switch to. We'll create empty placeholder scenes for our tools.

You can do this using the Gemini CLI for speed.

    mkdir -p agency/scenes/world_builder
    mkdir -p agency/scenes/case_creator
    mkdir -p agency/scenes/validator
    
    touch agency/scenes/world_builder/world_builder.tscn
    touch agency/scenes/case_creator/case_creator.tscn
    touch agency/scenes/validator/validator.tscn
    

Now, let's turn these empty files into actual Godot scenes.

1.  **Create World Builder Scene:**
    
    -   In Godot, go to **Scene > New Scene**.
        
    -   Click **User Interface** to create a `Control` node as the root. Rename it `WorldBuilder`.
        
    -   Save the scene (`Ctrl+S`) in the new folder: `scenes/world_builder/world_builder.tscn`.
        
    -   Add a `Label` as a child of `WorldBuilder` and set its text to "World Builder" so we know it's working. Use the **Anchors Preset** to center it.
        
2.  **Create Case Creator Scene:**
    
    -   **Scene > New Scene**.
        
    -   Create a `Control` root node, rename it `CaseCreator`.
        
    -   Save it as `scenes/case_creator/case_creator.tscn`.
        
    -   Add a centered `Label` with the text "Case Creator".
        
3.  **Create Validator Scene:**
    
    -   **Scene > New Scene**.
        
    -   Create a `Control` root node, rename it `Validator`.
        
    -   Save it as `scenes/validator/validator.tscn`.
        
    -   Add a centered `Label` with the text "Validator".
        

### 4\. Scripting the Main Menu Navigation

Now we'll add a script to `Main` to handle the button presses.

1.  **Attach a Script:** Select the `Main` root node. In the **Inspector**, click the script icon and choose **New Script**. Name it `main.gd` and save it in the `scripts/main_ui` folder.
    
2.  **Edit the Script:** Double-click the new `main.gd` file to open it in the script editor. Replace the contents with this:
    
        # agency/scripts/main_ui/main.gd
        extends Control
        
        # Preload the scenes we will switch to.
        # Using packed scenes is more efficient than loading by string path every time.
        var world_builder_scene = preload("res://scenes/world_builder/world_builder.tscn")
        var case_creator_scene = preload("res://scenes/case_creator/case_creator.tscn")
        var validator_scene = preload("res://scenes/validator/validator.tscn")
        
        func _ready():
            # Connect the button signals to functions in this script.
            # We connect the "pressed" signal which is emitted when a button is clicked.
            $CenterContainer/VBoxContainer/WorldBuilderButton.pressed.connect(_on_world_builder_button_pressed)
            $CenterContainer/VBoxContainer/CaseCreatorButton.pressed.connect(_on_case_creator_button_pressed)
            $CenterContainer/VBoxContainer/ValidatorButton.pressed.connect(_on_validator_button_pressed)
            $CenterContainer/VBoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)
        
        # This function will be called when the World Builder button is pressed.
        func _on_world_builder_button_pressed():
            # The get_tree().change_scene_to_packed() function unloads the current scene
            # and loads the new one.
            get_tree().change_scene_to_packed(world_builder_scene)
        
        # This function will be called when the Case Creator button is pressed.
        func _on_case_creator_button_pressed():
            get_tree().change_scene_to_packed(case_creator_scene)
        
        # This function will be called when the Validator button is pressed.
        func _on_validator_button_pressed():
            get_tree().change_scene_to_packed(validator_scene)
        
        # This function will be called when the Quit button is pressed.
        func _on_quit_button_pressed():
            # get_tree().quit() safely closes the application.
            get_tree().quit()
        
        
    
    **Alternative to Typing Connections:** You can also connect signals visually. Select a button, go to the **Node** dock (next to the Inspector), click on the `pressed()` signal, and connect it to the `Main` node. Godot will automatically create the function stub for you.
    
3.  **Test It:** Save everything and run the project (**F5**). Your main menu should appear. Clicking the "World Builder", "Case Creator", or "Validator" buttons should take you to your placeholder scenes. The "Quit" button should close the application.
    

You now have a solid, navigable structure for the entire application. In the next walkthrough, we will begin building the UI for the **World Builder**.





