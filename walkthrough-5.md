# **Walkthrough 5: Loading and Displaying Case Data**

With our case file populated, it's time to write the code that reads this data and displays it visually. We will create a script for our Main scene that loads the case resource and then generates GraphNode elements for each piece of information (characters, locations, and clues) on our GraphEdit board.

### **1\. Attaching a Script to the Main Node**

First, our Main node needs a script to control its behavior.

1. Open the main.tscn scene.  
2. Select the root node, Main, in the **Scene** dock.  
3. In the **Inspector** dock, you'll see a button with a scroll icon that says **Attach a new or existing script to the selected node**. Click it.  
4. The "Attach Node Script" dialog will appear.  
   * **Language**: Should be GDScript.  
   * **Inherits**: Should be MarginContainer.  
   * **Path**: Godot will suggest a path. Let's change it to res://scenes/main\_ui/main.gd.  
5. Click **Create**. The script editor will open with a new script file.

### **2\. Writing the Script**

Replace the default content of main.gd with the following code. We'll go through it section by section.

extends MarginContainer

\# Preload the case file. Preloading loads the file when the game compiles,  
\# which is efficient if you know you'll need the resource right away.  
@export var case\_file: CaseResource \= preload("res://cases/case\_01.tres")

\# Node references that we will get in the \_ready function.  
\# Using the % syntax is a convenient way to get nodes.  
@onready var case\_graph: GraphEdit \= %CaseGraph

\# Called when the node enters the scene tree for the first time.  
func \_ready() \-\> void:  
	\# Check if the case file was loaded successfully  
	if not case\_file:  
		print\_err("Case file not loaded. Make sure the path is correct.")  
		return  
	  
	\# Call the function to display the data  
	display\_case\_data()

\# This function clears the graph and populates it from the case\_file resource.  
func display\_case\_data() \-\> void:  
	\# Clear any existing nodes from the graph to prevent duplicates  
	for child in case\_graph.get\_children():  
		child.queue\_free()

	var current\_position \= Vector2(100, 100\)  
	var horizontal\_offset \= 400  
	var vertical\_offset \= 200

	\# Display Characters  
	for character in case\_file.characters:  
		create\_graph\_node(character.name, current\_position)  
		current\_position.y \+= vertical\_offset

	\# Reset position for the next column  
	current\_position \= Vector2(100 \+ horizontal\_offset, 100\)

	\# Display Locations  
	for location in case\_file.locations:  
		create\_graph\_node(location.name, current\_position)  
		current\_position.y \+= vertical\_offset  
	  
	\# Reset position for the next column  
	current\_position \= Vector2(100 \+ horizontal\_offset \* 2, 100\)

	\# Display Clues  
	for clue in case\_file.clues:  
		create\_graph\_node(clue.name, current\_position)  
		current\_position.y \+= vertical\_offset

\# A helper function to create and configure a new GraphNode.  
func create\_graph\_node(title: String, position: Vector2) \-\> void:  
	var graph\_node \= GraphNode.new()  
	graph\_node.title \= title  
	graph\_node.position\_offset \= position  
	  
	\# In Godot 4, you set the position using position\_offset, not offset.  
	  
	case\_graph.add\_child(graph\_node)

### **3\. Understanding the Code**

* **extends MarginContainer**: Confirms the script is attached to a MarginContainer node.  
* **@export var case\_file: CaseResource \= preload(...)**: This line does two things. @export makes the case\_file variable visible in the Inspector, so you could drag a different case file onto it if you wanted. preload loads the case\_01.tres file when the game starts.  
* **@onready var case\_graph: GraphEdit \= %CaseGraph**: @onready is a keyword that delays initialization of a variable until the node is fully ready. The %CaseGraph syntax is a shorthand in Godot 4 to get a direct reference to the node named "CaseGraph" in the scene. It's much cleaner than using get\_node("path/to/node").  
* **\_ready()**: This is one of Godot's lifecycle functions. It's called automatically when the node (and all its children) have been added to the scene. It's the perfect place to do initial setup. We simply call our main display function here.  
* **display\_case\_data()**: This is the core logic.  
  * It first loops through any existing children of the case\_graph and removes them. This is good practice to ensure the board is clean before we add new things.  
  * It then iterates through the characters, locations, and clues arrays from our loaded case\_file.  
  * For each item, it calls create\_graph\_node(), passing in the item's name and a calculated position to arrange the nodes in columns.  
* **create\_graph\_node()**: This is a helper function to keep our code DRY (Don't Repeat Yourself). It creates a new GraphNode instance, sets its title and position (position\_offset is the correct property in Godot 4), and adds it as a child to our case\_graph.

### **4\. Run the Game**

Save the script (Ctrl+S) and the scene (Ctrl+S). Now, press **F5** to run the project.

You should now see your case board come to life\! The GraphEdit area will be populated with nodes for Alistair Finch, Nora Vance, Silas Croft, the workshop, the tavern, and the workbench clue, all neatly arranged.

You have successfully bridged the gap between your data and your game's visuals. In the final walkthrough, we'll add interactivity, allowing the player to click on these nodes to see more detailed information.