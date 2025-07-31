# Walkthrough 11: Building the UI - Tabs and Editors

With the foundation in place, let's build the user interface for the World Builder. We'll use a `TabContainer` to organize the different sections for creating factions, districts, characters, and so on.

### 1\. Setting up the Main Layout

Open `world_builder.tscn`. We'll add a main `VBoxContainer` and a `TabContainer` to structure the UI.

1.  Add a `VBoxContainer` as a child of the `WorldBuilder` root node. Name it `MainContainer`.
    
2.  In the Layout menu for `MainContainer`, select `Full Rect`.
    
3.  Add a `TabContainer` as a child of `MainContainer`. Name it `EditorTabs`.
    
4.  In the Inspector for `EditorTabs`, set its `Size Flags > Vertical` to `Expand Fill`.
    

### 2\. Creating the Meta Section

The first tab will be for the world's metadata (name and description).

1.  Create a new scene for our meta section. The root should be a `VBoxContainer`. Save it as `agency/scenes/components/meta/meta_section.tscn`.
    
2.  Add a script to the root node: `agency/scenes/components/meta/meta_section.gd`.
    
3.  In `meta_section.tscn`, add a `Label` and a `LineEdit` for the world name. Then add another `Label` and a `TextEdit` for the description.
    
4.  In `world_builder.tscn`, instance `meta_section.tscn` as a child of `EditorTabs`. Rename the instanced node to "Meta".
    

### 3\. Creating the Faction Section

Now, let's create the section for managing factions.

1.  Create a new scene with a `VBoxContainer` root named `FactionSection`. Save it as `agency/scenes/components/faction/faction_section.tscn`.
    
2.  Add a script to it: `agency/scenes/components/faction/faction_section.gd`.
    
3.  Inside `FactionSection`, add a `Button` to "Add Faction" and a `VBoxContainer` to hold the list of factions.
    
4.  In `world_builder.tscn`, instance `faction_section.tscn` as a child of `EditorTabs`. Rename it to "Factions".
    

### 4\. Creating the Faction Card

We need a reusable component to display and edit a single faction.

1.  Create a new scene with a `PanelContainer` root named `FactionCard`. Save it as `agency/scenes/components/faction/faction_card.tscn`.
    
2.  Add a script: `agency/scenes/components/faction/faction_card.gd`.
    
3.  Inside `FactionCard`, add `LineEdit` nodes for the faction's name and description, and any other properties from `faction_resource.gd`.
    

Now we have the basic structure. The `faction_section.gd` script will be responsible for creating new `FactionCard` instances when the "Add Faction" button is pressed.

**\[Gemini CLI Task\]**

This is a great point to use the Gemini CLI. You can now ask it to create the sections and cards for Districts, Characters, Locations, and Items. You would provide the `faction_section.tscn`, `faction_card.tscn`, and their scripts as examples and ask it to generate the equivalents for the other resource types.

For example: "Using `faction_section.tscn` and `faction_card.tscn` as a reference, create the scenes and scripts for a `DistrictSection` and `DistrictCard` to manage `DistrictResource`s."





