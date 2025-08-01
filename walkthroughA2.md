# Godot World Builder: Step-by-Step Guide

This document provides a complete, beginner-friendly walkthrough for creating the "World Builder" user interface in the Godot Engine (version 4.1+). We will replicate the three-pane layout from our HTML mockup, focusing on structure, theme, and layout first, before adding functionality with GDScript.

## Phase 1: Project Setup & Theming

Before we build the scene, we need to set up the project's aesthetic foundation: the fonts and colors.

### 1.1. Create a Global Theme

A Theme resource allows us to define the look of UI components (called Control nodes) for the entire project, ensuring a consistent style.

1.  In the **FileSystem** dock (usually bottom-left), right-click on the `res://` folder and select **New -> Folder**. Name it `themes`.
    
2.  Right-click the new `themes` folder and select **New -> Resource...**.
    
3.  In the dialog, search for and select `Theme`, then click **Create**. Save it as `main_theme.tres`.
    
4.  Double-click `main_theme.tres` to open it in the **Theme Editor** (bottom panel).
    

### 1.2. Import Fonts & Define Colors

1.  **Import Fonts:**
    
    -   Drag your font files (`Inter-VariableFont_opsz,wght.ttf` and `PoiretOne-Regular.ttf`) from your computer's file manager directly into Godot's **FileSystem** dock.
        
    -   Double-click `main_theme.tres` again.
        
    -   In the Theme Editor, click the **Manage Items** button.
        
    -   Under the **Default Font** section, find the **Font** property. Click the dropdown next to it (`<empty>`) and select **New FontVariation**.
        
    -   Click the new `FontVariation` resource to expand its properties in the **Inspector** (right-hand panel).
        
    -   Find the **Base Font** property and drag `Inter-VariableFont_opsz,wght.ttf` from the FileSystem onto it.
        
    -   Set the **Default Font Size** to `14`.
        
2.  **Add a Second Font:**
    
    -   In the Theme Editor, click **Add Class Items**.
        
    -   In the popup, select `Label`.
        
    -   Now, in the main Theme Editor view, you'll see a "Label" type. Click the **+** icon next to it and select **Add Font**. Name this new font `display_font`.
        
    -   Click the `<empty>` value next to `display_font` and create a new `FontVariation`.
        
    -   Just like before, set its **Base Font**, but this time use `PoiretOne-Regular.ttf`.
        
3.  **Define Colors:**
    
    -   In the Theme Editor, find the `PanelContainer` type (or add it via **Add Class Items** if it's not there).
        
    -   Click the **+** icon next to it and select **Add Stylebox**. Choose `StyleBoxFlat`.
        
    -   Click the new `StyleBoxFlat` to edit it in the Inspector. Set its **Bg Color** to our dark gray: `#1f2937`.
        
    -   Repeat this process to define the core colors from our mockup for different node types. The most important ones are:
        
        -   **Button:** Create `StyleBoxFlat` styles for **Normal**, **Hover**, **Pressed**, and **Disabled**. Use the gray, cyan, and gold colors. Set the **Font Color** properties as well.
            
        -   **TabContainer:** Define styles for the **Tab Selected** and **Tab Unselected** to get the cyan highlight effect.
            
        -   **LineEdit / TextEdit:** Set the `StyleBoxFlat` for the **Normal** and **Focus** states, and define the **Font Color**.
            

## Phase 2: Building the Main Scene (`WorldBuilder.tscn`)

This is where we construct the three-pane layout.

1.  Go to **Scene -> New Scene**.
    
2.  Choose **User Interface** as the root node. This will create a `Control` node.
    
3.  Click on the `Control` node and rename it to `WorldBuilder`.
    
4.  In the **Inspector**, go to the **Layout** section, click the **Anchors Preset** icon (the square grid), and select **Full Rect**. This makes it fill the game window.
    
5.  In the **Scene** tree, right-click `WorldBuilder` and select **Add Child Node**.
    
6.  Search for and add an `HSplitContainer`. This node creates a vertical splitter.
    
7.  Select the `HSplitContainer` and set its **Anchors Preset** to **Full Rect** as well.
    
8.  In the Inspector, find the **Theme Overrides -> Constants** section for the `HSplitContainer`. Check the box next to **Separation** and set it to `6`. This makes the draggable splitter thicker.
    

Your scene tree should look like this:

    - WorldBuilder (Control)
      - HSplitContainer
    

### 2.1. Create the Three Panes

The `HSplitContainer` automatically creates two layout regions. We will add our three main panels to it.

1.  **Left Navigation Pane:**
    
    -   Right-click `HSplitContainer` and add a `PanelContainer`. Rename it `NavPane`.
        
    -   In the Inspector, under **Layout -> Custom Minimum Size**, set `x` to `96`. This gives it the narrow starting width.
        
2.  **Right Content Area (which will be split again):**
    
    -   Right-click `HSplitContainer` and add another `HSplitContainer`. Rename it `ContentSplitter`. This will hold the asset list and the detail view.
        
    -   Select `ContentSplitter` and find its **Size Flags** in the Inspector. Set **Horizontal** to **Expand, Fill**.
        
3.  **Asset List Pane:**
    
    -   Right-click `ContentSplitter` and add a `PanelContainer`. Rename it `AssetListPane`.
        
    -   Set its **Custom Minimum Size** `x` to `250`.
        
    -   Set its **Size Flags -> Horizontal** to **Expand, Fill**.
        
4.  **Detail Pane:**
    
    -   Right-click `ContentSplitter` and add a `PanelContainer`. Rename it `DetailPane`.
        
    -   Set its **Size Flags -> Horizontal** to **Expand, Fill**.
        

Now your scene tree is structured for the three-pane layout:

    - WorldBuilder (Control)
      - HSplitContainer
        - NavPane (PanelContainer)
        - ContentSplitter (HSplitContainer)
          - AssetListPane (PanelContainer)
          - DetailPane (PanelContainer)
    

## Phase 3: Populating the Panes

Now we fill each of the three `PanelContainer`s with the UI elements. **Pay close attention to the new, explicit node names.**

### 3.1. NavPane (Left Sidebar)

1.  Add a `VBoxContainer` as a child of `NavPane`. **Rename it `NavLayout`**.
    
2.  Add a `Label` as a child of `NavLayout`.
    
    -   Set its **Text** to `A`.
        
    -   Under **Theme Overrides -> Fonts**, assign our `display_font`.
        
    -   Set **Horizontal Alignment** to **Center**.
        
3.  Add another `VBoxContainer` to `NavLayout`. **Rename it `NavButtonsContainer`**. This will hold the buttons.
    

### 3.2. AssetListPane (Middle Column)

1.  Add a `VBoxContainer` to `AssetListPane`. **Rename it `ListLayout`**.
    
2.  Add a `PanelContainer` to `ListLayout` for the header.
    
    -   Inside this header panel, add a `Label`. **Rename** it `ListTitle`. Set its **Text** to `World Builder`.
        
3.  Add a `ScrollContainer` to `ListLayout`.
    
    -   Set its **Size Flags -> Vertical** to **Expand, Fill**.
        
4.  Add a `VBoxContainer` to the `ScrollContainer`. **Rename** it `AssetListContainer`. This is where the actual asset items will be added by our script.
    

### 3.3. DetailPane (Right Column)

This pane will contain two main states: the placeholder and the form.

1.  **Placeholder View:**
    
    -   Add a `CenterContainer` to `DetailPane`. **Rename** it `DetailPlaceholder`.
        
    -   Add a `VBoxContainer` to the `CenterContainer`.
        
    -   Add a `TextureRect` (for an icon) and two `Label`s to this `VBoxContainer`. Configure their text as in the mockup.
        
2.  **Form View:**
    
    -   Add a `PanelContainer` to `DetailPane`. **Rename** it `FormView`. Set its **Anchors Preset** to **Full Rect**. By default, set its **Visible** property (in the Inspector) to `false`.
        
    -   Add an `HBoxContainer` to `FormView`.
        
    -   **Image Section (Left):**
        
        -   Add a `PanelContainer` to the `HBoxContainer`. Set its **Size Flags -> Horizontal** to **Expand, Fill** and its **Stretch Ratio** to `0.33`.
            
        -   Inside, add a `VBoxContainer`. **Rename it `ImageSectionLayout`**. Then add a `TextureRect` for the image and a `Label`. **Rename the Label `CardTitle`**.
            
    -   **Form Section (Right):**
        
        -   Add a `VBoxContainer` to the `HBoxContainer`. **Rename it `FormSectionLayout`**. Set its **Stretch Ratio** to `0.67`.
            
        -   Inside `FormSectionLayout`, add a `TabContainer`.
            
        -   Set the `TabContainer`'s **Size Flags -> Vertical** to **Expand, Fill**.
            
        -   Add a final `HBoxContainer` at the bottom of `FormSectionLayout`. **Rename it `FooterButtons`**. Add two `Button` nodes to it. **Rename them `CancelButton` and `SaveButton`**.
            

## Phase 4: The Controller Script (`world_builder.gd`)

With the visual layout complete, we add a script to make it interactive.

1.  Select the root `WorldBuilder` node.
    
2.  In the Inspector, click the script icon and select **New Script**.
    
3.  Save it as `world_builder.gd`.
    

Here is the **corrected** code structure. The node paths now match the explicit names from Phase 3.

    # world_builder.gd
    extends Control
    
    # --- UI Node References ---
    # These paths MUST EXACTLY match the names in your scene tree from Phase 3.
    # Double-check them if you get "Node not found" errors.
    
    # Path: HSplitContainer -> NavPane -> NavLayout -> NavButtonsContainer
    @onready var nav_buttons_container = $HSplitContainer/NavPane/NavLayout/NavButtonsContainer
    
    # Path: HSplitContainer -> ContentSplitter -> AssetListPane -> ListLayout -> PanelContainer -> ListTitle
    @onready var list_title = $HSplitContainer/ContentSplitter/AssetListPane/ListLayout/PanelContainer/ListTitle
    
    # Path: HSplitContainer -> ContentSplitter -> AssetListPane -> ListLayout -> ScrollContainer -> AssetListContainer
    @onready var asset_list_container = $HSplitContainer/ContentSplitter/AssetListPane/ListLayout/ScrollContainer/AssetListContainer
    
    # Path: HSplitContainer -> ContentSplitter -> DetailPane -> DetailPlaceholder
    @onready var detail_placeholder = $HSplitContainer/ContentSplitter/DetailPane/DetailPlaceholder
    
    # Path: HSplitContainer -> ContentSplitter -> DetailPane -> FormView
    @onready var form_view = $HSplitContainer/ContentSplitter/DetailPane/FormView
    
    # Path: HSplitContainer -> ContentSplitter -> DetailPane -> FormView -> HBoxContainer -> PanelContainer -> ImageSectionLayout -> CardTitle
    @onready var card_title = $HSplitContainer/ContentSplitter/DetailPane/FormView/HBoxContainer/PanelContainer/ImageSectionLayout/CardTitle
    
    # Path: HSplitContainer -> ContentSplitter -> DetailPane -> FormView -> HBoxContainer -> FormSectionLayout -> TabContainer
    @onready var form_tabs = $HSplitContainer/ContentSplitter/DetailPane/FormView/HBoxContainer/FormSectionLayout/TabContainer
    
    # Path: HSplitContainer -> ContentSplitter -> DetailPane -> FormView -> HBoxContainer -> FormSectionLayout -> FooterButtons -> CancelButton
    @onready var cancel_button = $HSplitContainer/ContentSplitter/DetailPane/FormView/HBoxContainer/FormSectionLayout/FooterButtons/CancelButton
    
    
    # --- Data ---
    # This dictionary mimics our asset data from the mockup.
    var asset_types = {
    	"characters": {
    		"label": "Characters",
    		"items": [
    			{"id": "char_01", "name": "Detective Miles", "description": "A grizzled detective with a past."},
    			{"id": "char_02", "name": "Isabella Dubois", "description": "A wealthy socialite with dark secrets."}
    		],
    		"tabs": ["Profile", "Relationships", "Background", "Notes"]
    	},
    	"locations": {
    		"label": "Locations",
    		"items": [
    			{"id": "loc_01", "name": "The Gilded Cage", "description": "An opulent nightclub for the city elite."}
    		],
    		"tabs": ["Description", "Inhabitants", "Events", "Map"]
    	},
    	"items": {
    		"label": "Items",
    		"items": [],
    		"tabs": ["Details", "History", "Significance"]
    	}
    }
    
    var current_asset_type = ""
    var current_item = null
    
    # Preload the scenes for our reusable UI components
    # NOTE: You must create these two simple scenes for the code to run.
    const AssetNavButton = preload("res://scenes/ui/asset_nav_button.tscn")
    const AssetListItem = preload("res://scenes/ui/asset_list_item.tscn")
    
    # --- Godot Functions ---
    
    func _ready():
    	# This function is called when the scene starts.
    	_setup_navigation()
    	
    	# Select the first asset type by default
    	if not asset_types.is_empty():
    		select_asset_type(asset_types.keys()[0])
    	
    	# Connect signals from the Cancel button
    	cancel_button.pressed.connect(_on_cancel_pressed)
    
    
    # --- UI Setup Functions ---
    
    func _setup_navigation():
    	# Clear any old buttons
    	for child in nav_buttons_container.get_children():
    		child.queue_free()
    	
    	# Create a button for each asset type
    	for type_key in asset_types:
    		var data = asset_types[type_key]
    		var nav_button = AssetNavButton.instantiate()
    		nav_button.set_label(data.label)
    		# Connect the button's pressed signal to our function
    		nav_button.pressed.connect(select_asset_type.bind(type_key))
    		nav_buttons_container.add_child(nav_button)
    
    func _update_asset_list():
    	# Clear the old list
    	for child in asset_list_container.get_children():
    		child.queue_free()
    	
    	# Get the data for the currently selected type
    	var type_data = asset_types[current_asset_type]
    	list_title.text = "All %s" % type_data.label
    	
    	# Add the "New Asset" button
    	var new_button = Button.new()
    	new_button.text = "New %s" % type_data.label.trim_suffix("s")
    	new_button.pressed.connect(show_detail_view.bind(null)) # Pass null for a new item
    	asset_list_container.add_child(new_button)
    	
    	# Add an item for each asset
    	for item_data in type_data.items:
    		var list_item = AssetListItem.instantiate()
    		list_item.set_data(item_data)
    		list_item.gui_input.connect(func(event): 
    			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
    				show_detail_view(item_data)
    		)
    		asset_list_container.add_child(list_item)
    
    
    # --- UI State Functions ---
    
    func select_asset_type(type_key: String):
    	current_asset_type = type_key
    	current_item = null
    	hide_detail_view()
    	_update_asset_list()
    
    func show_detail_view(item_data):
    	current_item = item_data
    	var type_data = asset_types[current_asset_type]
    	
    	if item_data:
    		card_title.text = item_data.name
    	else:
    		card_title.text = "New %s" % type_data.label.trim_suffix("s")
    	
    	# Clear and populate tabs (simplified)
    	form_tabs.clear_tabs()
    	for tab_name in type_data.tabs:
    		var label = Label.new()
    		label.text = "Content for %s" % tab_name
    		form_tabs.add_child(label)
    		form_tabs.set_tab_title(form_tabs.get_tab_count() - 1, tab_name)
    		
    	detail_placeholder.hide()
    	form_view.show()
    
    func hide_detail_view():
    	form_view.hide()
    	detail_placeholder.show()
    
    
    # --- Signal Handlers ---
    
    func _on_cancel_pressed():
    	hide_detail_view()
    
    

## Phase 5: Troubleshooting

### "I see a blank screen!" or "I get a 'Node not found' error."

This is the most common issue and it's 99% certain to be a mismatch between the node paths in the script and the node names in your Scene Tree.

1.  **Check Your Names:** Go through the Scene Tree and compare every single node name against the names specified in **Phase 3** of this guide. Pay special attention to the container nodes I asked you to rename, like `NavLayout`, `ListLayout`, `ImageSectionLayout`, and `FormSectionLayout`.
    
2.  **Check Your Paths:** Look at the `@onready var` lines at the top of the script. I have added comments above each one showing the exact path it expects. For example: `# Path: HSplitContainer -> NavPane -> NavLayout -> NavButtonsContainer` `@onready var nav_buttons_container = $HSplitContainer/NavPane/NavLayout/NavButtonsContainer` Trace this path in your Scene Tree. If your tree doesn't match this structure and naming exactly, the script will fail.
    
3.  **The Easiest Fix:** In the script, you can right-click a node path (the part in quotes after the `$`) and select "Copy Node Path". Then, go to your Scene Tree, right-click the correct node, and select "Paste Node Path". This ensures the path is 100% correct.
    

By ensuring your scene tree and script paths are perfectly aligned, the blank screen issue will be resolved.





