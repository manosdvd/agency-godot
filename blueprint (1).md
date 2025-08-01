# **Project Blueprint: The Agency (Godot Edition) \- Comprehensive**

## **1\. Core Vision & Philosophy**

* **Product:** "The Agency" is an integrated authoring tool and interactive dossier for mystery writers, built in the **Godot Engine**. It is a visual-first environment for world-building, plot construction, and logic validation.  
* **Core Philosophy:** The software must be an inspiring and tactile creative partner. The **"Holographic Art Deco"** aesthetic is paramount, blending neo-noir atmosphere, elegant geometric forms, and a clean, diegetic UI. The goal is to make the author feel like a futuristic detective assembling a case, not a data entry clerk.  
* **Development Methodology:** A **Human-AI Symbiosis**. The human developer architects the core systems, logic, and interactions. An AI assistant (Gemini) is used for "vibe coding"—generating placeholder content, thematic text, and simple, repetitive scripts to rapidly flesh out the world's atmosphere.

## **2\. Godot-Centric Architecture**

While the Python version used a formal MVC pattern, Godot's architecture achieves a similar separation of concerns through its node, script, and resource systems.

* **Model (The Data):** The application's data will be defined by **custom GDScript Resources** (class\_name). These are script files that act as data containers (e.g., CharacterResource.gd, CaseResource.gd). They are the single source of truth. Data will be persisted to the disk as .tres (Godot's text resource format) or .json files for portability.  
* **View (The UI):** The entire UI will be constructed from Godot's **Control Nodes**. Reusable components (like asset cards) will be built as self-contained **Scenes** (.tscn files) that can be instanced throughout the application. The View's only job is to display the data from the Model (the resources).  
* **Controller (The Logic):** The logic resides in the **GDScript files attached to the UI Scenes**. These scripts will handle user input (e.g., a button press), emit signals, modify the data in the custom Resources (the Model), and then update the UI nodes to reflect those changes.  
* **Global Singletons (AutoLoads):** Core systems that need to be globally accessible will be implemented as Singletons.  
  * DataManager: Handles all file I/O—saving and loading World and Case resources.  
  * Validator: A silent, background assistant that constantly checks the active Case resource for logical inconsistencies.  
  * AIAssistant: Manages all communication with the Gemini API via Godot's HTTPRequest node.

## **3\. Comprehensive Data Schema (GDScript Resources)**

This is the detailed translation of the Python blueprint's data fields into GDScript class\_name resources. This ensures no details are lost in the conversion.

### **3.1. World Builder Resources**

These scripts should be saved in a res://data/resources/ folder.  
**File: res://data/resources/district\_resource.gd**  
`# district_resource.gd`  
`extends Resource`  
`class_name DistrictResource`

`@export var id: String = ""`  
`@export var district_name: String = ""`  
`@export_multiline var description: String = ""`  
`@export var wealth_class: String = "" # e.g., "Opulent", "Working Class"`  
`@export_multiline var atmosphere: String = ""`  
`@export var key_locations: PackedStringArray`  
`@export var population_density: String = "" # e.g., "Dense", "Sparse"`  
`@export var notable_features: PackedStringArray`  
`@export var dominant_faction: String = "" # Should link to a FactionResource.id`

**File: res://data/resources/location\_resource.gd**  
`# location_resource.gd`  
`extends Resource`  
`class_name LocationResource`

`@export var id: String = ""`  
`@export var location_name: String = ""`  
`@export var location_type: String = "" # e.g., "Bar", "Apartment", "Dock"`  
`@export_multiline var description: String = ""`  
`@export var district: String = "" # Should link to a DistrictResource.id`  
`@export var owning_faction: String = "" # Should link to a FactionResource.id`  
`@export_range(0, 100, 1) var danger_level: int = 50`  
`@export var population: String = ""`  
`@export var image_path: String = "" # Path to texture`  
`@export var key_characters: PackedStringArray # Links to CharacterResource.id`  
`@export var associated_items: PackedStringArray # Links to ItemResource.id`  
`@export_multiline var accessibility: String = ""`  
`@export var is_hidden: bool = false`  
`@export var clues_present: PackedStringArray # Links to ClueResource.id`  
`@export_multiline var internal_logic_notes: String = ""`

**File: res://data/resources/faction\_resource.gd**  
`# faction_resource.gd`  
`extends Resource`  
`class_name FactionResource`

`@export var id: String = ""`  
`@export var faction_name: String = ""`  
`@export var archetype: String = "" # e.g., "Syndicate", "Corporation"`  
`@export_multiline var description: String = ""`  
`@export_multiline var ideology: String = ""`  
`@export var headquarters: String = "" # Links to a LocationResource.id`  
`@export_multiline var resources: String = ""`  
`@export var image_path: String = ""`  
`@export var ally_factions: PackedStringArray # Links to FactionResource.id`  
`@export var enemy_factions: PackedStringArray # Links to FactionResource.id`  
`@export var members: PackedStringArray # Links to CharacterResource.id`  
`@export var influence: String = "" # e.g., "City-wide", "Neighborhood"`  
`@export var public_perception: String = ""`

**File: res://data/resources/character\_resource.gd**  
`# character_resource.gd`  
`extends Resource`  
`class_name CharacterResource`

`@export var id: String = ""`  
`@export var full_name: String = ""`  
`@export var alias: String = ""`  
`@export var age: int = 30`  
`@export var gender: String = ""`  
`@export var employment: String = ""`  
`@export_multiline var biography: String = ""`  
`@export var image_path: String = ""`  
`@export var faction: String = "" # Links to a FactionResource.id`  
`@export var wealth_class: String = ""`  
`@export var district: String = "" # Links to a DistrictResource.id`  
`@export var allies: PackedStringArray # Links to CharacterResource.id`  
`@export var enemies: PackedStringArray # Links to CharacterResource.id`  
`@export var items: PackedStringArray # Links to ItemResource.id`  
`@export var archetype: String = "" # e.g., "Femme Fatale", "Hard-boiled Detective"`  
`@export_multiline var personality: String = ""`  
`@export_multiline var values: String = ""`  
`@export_multiline var flaws_handicaps: String = ""`  
`@export_multiline var quirks: String = ""`  
`@export_multiline var characteristics: String = ""`  
`@export var alignment: Vector2i = Vector2i(1, 1) # For 3x3 grid: (0,0) to (2,2)`  
`@export_multiline var motivations: String = ""`  
`@export_multiline var secrets: String = ""`  
`@export_multiline var vulnerabilities: String = ""`  
`@export var voice_model: String = "" # For potential TTS`  
`@export_multiline var dialogue_style: String = ""`  
`@export_multiline var expertise: String = ""`  
`@export_range(0, 100, 1) var honesty: int = 50`  
`@export_range(0, 100, 1) var victim_likelihood: int = 50`  
`@export_range(0, 100, 1) var killer_likelihood: int = 50`  
`@export_multiline var portrayal_notes: String = ""`

`# Sleuth-specific fields`  
`@export var is_sleuth: bool = false`  
`@export var city: String = ""`  
`@export_multiline var primary_arc: String = ""`

**File: res://data/resources/item\_resource.gd**  
`# item_resource.gd`  
`extends Resource`  
`class_name ItemResource`

`@export var id: String = ""`  
`@export var item_name: String = ""`  
`@export var image_path: String = ""`  
`@export var item_type: String = "" # e.g., "Weapon", "Document", "Personal Effect"`  
`@export_multiline var description: String = ""`  
`@export_multiline var use: String = ""`  
`@export var is_possible_means: bool = false`  
`@export var is_possible_motive: bool = false`  
`@export var is_possible_opportunity: bool = false`  
`@export var default_location: String = "" # Links to LocationResource.id`  
`@export var default_owner: String = "" # Links to CharacterResource.id`  
`@export_multiline var significance: String = ""`  
`@export_multiline var clue_potential: String = ""`  
`@export var value: String = ""`  
`@export var condition: String = ""`  
`@export_multiline var unique_properties: String = ""`

### **3.2. Case Builder Resources**

**File: res://data/resources/clue\_resource.gd**  
`# clue_resource.gd`  
`extends Resource`  
`class_name ClueResource`

`@export var id: String = ""`  
`@export var is_critical: bool = false`  
`@export var character_implicated: String = "" # Links to CharacterResource.id`  
`@export var is_red_herring: bool = false`  
`@export var red_herring_type: String = "" # e.g., "False Lead", "Misinterpretation"`  
`@export_multiline var mechanism_of_misdirection: String = ""`  
`@export var debunking_clue: String = "" # Links to another ClueResource.id`  
`@export var source: String = "" # e.g., "Witness Testimony", "Forensics"`  
`@export_multiline var summary: String = ""`  
`@export_multiline var discovery_path: String = ""`  
`@export_multiline var presentation_method: String = ""`  
`@export var knowledge_level: String = "" # e.g., "Common", "Expert"`  
`@export var dependencies: PackedStringArray # Other clues needed first`  
`@export_multiline var required_actions: String = ""`  
`@export_multiline var reveals_unlocks: String = ""`  
`@export var associated_item: String = "" # Links to ItemResource.id`  
`@export var associated_location: String = "" # Links to LocationResource.id`  
`@export var associated_character: String = "" # Links to CharacterResource.id`

**File: res://data/resources/interview\_resource.gd**  
`# interview_resource.gd`  
`# Represents a single Q&A block in an interview with a character.`  
`extends Resource`  
`class_name InterviewResource`

`@export_multiline var question: String = ""`  
`@export_multiline var answer: String = ""`  
`@export var is_lie: bool = false`  
`@export var debunking_clue: String = "" # Links to ClueResource.id`  
`@export var is_clue: bool = false`  
`@export var clue_revealed: String = "" # Links to ClueResource.id`  
`@export var provides_item: String = "" # Links to ItemResource.id`

**File: res://data/resources/case\_resource.gd**  
`# case_resource.gd`  
`extends Resource`  
`class_name CaseResource`

`# --- Case Meta ---`  
`@export var victim: String = "" # Links to CharacterResource.id`  
`@export var culprit: String = "" # Links to CharacterResource.id`  
`@export var crime_scene: String = "" # Links to LocationResource.id`  
`@export var murder_weapon: String = "" # Links to ItemResource.id`  
`@export var weapon_is_hidden: bool = false`  
`@export var means_clue: String = "" # Links to ClueResource.id`  
`@export var motive_clue: String = "" # Links to ClueResource.id`  
`@export var opportunity_clue: String = "" # Links to ClueResource.id`  
`@export var red_herring_clues: PackedStringArray # Links to ClueResource.id`  
`@export var narrative_viewpoint: String = "" # e.g., "First Person (Sleuth)"`  
`@export var narrative_tense: String = "" # e.g., "Past Tense"`  
`@export_multiline var core_mystery_solution: String = ""`  
`@export_multiline var ultimate_reveal_scene: String = ""`  
`@export_multiline var opening_monologue: String = ""`  
`@export_multiline var successful_denouement: String = ""`  
`@export_multiline var failed_denouement: String = ""`

`# --- Case Data ---`  
`# Dictionary where key is Character.id and value is an Array of InterviewResources`  
`@export var interviews: Dictionary = {}`  
`# Dictionary where key is Location.id and value is a PackedStringArray of Clue.id's`  
`@export var location_clues: Dictionary = {}`  
`# Array of all ClueResources associated with this case`  
`@export var clues: Array[ClueResource]`

## **4\. Scene & Node Implementation Strategy**

* **Main UI (Main.tscn):** A root Control node containing a TabContainer.  
  * **Tab 1: "World Builder"**: Contains UI for creating and editing Districts, Locations, Factions, Characters, and Items.  
  * **Tab 2: "Case Creator"**: Contains UI for editing the CaseResource and the Murder Board.  
* **Asset Cards (AssetCard.tscn):** A reusable scene based on PanelContainer. It will have a script that takes a resource (e.g., CharacterResource) and dynamically populates its child nodes (Label, TextureRect, etc.).  
* **Specialized Input Controls:**  
  * **Sliders (HSlider):** For danger\_level, victim\_likelihood, etc.  
  * **Alignment Grid:** A GridContainer with 9 Button nodes. Clicking a button updates the alignment Vector2i in the CharacterResource and provides visual feedback.  
  * **Dynamic Dropdowns (OptionButton):** Fields linking to other assets (e.g., Character's Faction) will be OptionButton nodes. The script will populate them with existing assets and include a "\[Create New...\]" option. Selecting this will trigger a popup or inline LineEdit to create a new asset resource on the fly.  
* **The Murder Board (MurderBoard.tscn):**  
  * **Core Node:** GraphEdit. This provides the pannable, zoomable canvas.  
  * **Nodes (GraphNode):** Each asset on the board (Clue, Suspect, Location) will be a GraphNode. The content *inside* each GraphNode will be an instance of a simplified AssetCard.tscn scene, showing key information.  
  * **Connections:** The connection\_request and disconnection\_request signals from the GraphEdit node will be connected to the Controller script. This script will update the underlying data resources (e.g., adding a clue to a character's clues\_present array) when the user draws a line.

## **5\. Core Logic & Roadmap**

### **Phase I: The Foundation & Editor**

* **Goal:** A stable, visually polished application with full manual data entry for all World and Case resources, backed by a real-time logical validator.  
* **Human Architect Tasks:**  
  1. Set up the Godot project, folder structure, and global Theme resource.  
  2. Create all GDScript Resource files as defined in Section 3\.  
  3. Build the main TabContainer UI and the various forms for editing each resource type, using the specified Godot Control nodes.  
  4. Implement the DataManager singleton for saving/loading world and case files.  
  5. Implement the Validator singleton. It will passively run in the \_process loop, checking the active CaseResource for the following conditions:  
     * **Solvability:** Does the case have a defined Victim, Culprit, Means, Motive, and Opportunity clue?  
     * **Interest:** Are there multiple witnesses and locations?  
     * **Deception Integrity:** Do red herring clues exist? Can they be debunked by other clues?  
     * **Culprit Confirmation:** Do sufficient clues point to the actual culprit?  
     * The Validator will display findings in a dedicated, non-intrusive UI panel, with each finding being a button that, when clicked, navigates the user to the relevant asset and field.

### **Phase II: The Murder Board**

* **Goal:** Implement the dynamic, node-based plot graph as the centerpiece of the Case Creator.  
* **Human Architect Tasks:**  
  1. Set up the GraphEdit scene.  
  2. Design the GraphNode scenes for displaying different asset types.  
  3. Write the GDScript logic to sync the GraphEdit view with the case data model in both directions (drawing a line updates the data; changing the data updates the lines).

### **Phase III: The AI Co-Pilot**

* **Goal:** Integrate AI-assisted authoring for content generation.  
* **Human Architect Tasks:**  
  1. Implement the AIAssistant singleton using the HTTPRequest node.  
  2. Create a global PopupMenu that appears on right-click over input fields.  
  3. Populate the menu with contextual actions ("Generate Description," "Suggest a Secret," "Fix This Logic Error").  
  4. Write the prompt-crafting logic in AIAssistant to send context-aware requests to the Gemini API and parse the JSON responses.