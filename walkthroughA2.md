# Walkthrough A2: The Data-Driven World Builder

This walkthrough details how to build the final, dynamic World Builder UI. This version is powered directly by your custom `Resource` scripts, making it a flexible and powerful tool for world-building.

### 1. Scene Setup: The Three-Pane Layout

Ensure your `world_builder.tscn` is structured as follows:

-   **`WorldBuilder` (Control)**: The root node.
    -   **`HSplitContainer`**: The main horizontal splitter.
        -   **`NavPane`**: The left navigation panel. It should contain a `VBoxContainer` (`NavLayout`) with buttons for each asset type.
        -   **`ContentSplitter`**: The right-side `HSplitContainer`.
            -   **`AssetListPane`**: The middle panel, containing a title and a `ScrollContainer` for asset cards.
            -   **`DetailPane`**: The right panel, which contains the `DetailPlaceholder` and the `FormView`.

### 2. The Controller Script: `world_builder.gd`

This script is the brain of the World Builder. It dynamically generates the UI based on your data models.

**Key Data Structures:**

-   `RESOURCE_PATHS`: A dictionary mapping asset type names (e.g., "Characters") to the file paths of their corresponding `Resource` scripts.
-   `FORM_TABS`: A dictionary that groups the properties of your resources into tabs for the UI.

**Core Logic:**

-   **`_ready()`**: Connects signals for navigation buttons, save/cancel buttons, and the image file dialog. It then scans for existing resources and selects the first asset type.
-   **`_scan_for_resources()`**: Populates the `asset_types` dictionary by finding all `.tres` files in the `res://cases` directory and grouping them by their script type.
-   **`select_asset_type(type_key)`**: Updates the UI to display the list of assets for the chosen type.
-   **`_generate_form_for_resource(resource)`**: This is the core of the dynamic UI. It reads the properties of the given `resource`, groups them into tabs using `FORM_TABS`, and creates the appropriate input controls (`LineEdit`, `TextEdit`, `HSlider`, `OptionButton`, etc.) for each property.
-   **`_get_editor_for_property(p, resource)`**: A helper function that creates and configures the correct input node based on a property's type and hints.
-   **`_on_save_pressed()`**: Iterates through all the generated input fields in the form, retrieves their values, updates the `current_resource`, and saves it to a `.tres` file. If it's a new resource, it generates a unique filename.
-   **Image Handling**: The `_on_upload_button_pressed` and `_on_image_file_dialog_file_selected` functions handle the logic for selecting and assigning an image to an asset.

### 3. How It All Works Together

1.  When the scene loads, `_ready` connects all the necessary signals.
2.  `_scan_for_resources` builds a complete picture of all the world assets you've created.
3.  Clicking a navigation button (e.g., "Characters") calls `select_asset_type`, which in turn calls `_update_asset_list` to show all your character resources.
4.  Clicking on a character card (or the "New Character" button) calls `show_detail_view`.
5.  `show_detail_view` passes the selected character resource to `_generate_form_for_resource`.
6.  `_generate_form_for_resource` dynamically builds the entire form, creating tabs and all the necessary input fields based on the properties defined in `character_resource.gd`.
7.  When you click "Save," `_on_save_pressed` intelligently extracts the data from the form and saves your changes, completing the cycle.

This data-driven approach means that if you add a new property to your `CharacterResource` script, it will automatically appear in the World Builder the next time you run it, without needing to change any of the UI code.
