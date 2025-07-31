# **Walkthrough 6: Making it Interactive**

We have a visual representation of our case, but it's static. The final step is to add interactivity. When the player clicks on a GraphNode (like "Alistair Finch"), we want their details to appear in the RightPanel. We will achieve this using Godot's signal system.

### **1\. Preparing the Right Panel for Details**

First, we need to add some UI elements to our RightPanel to display the information.

1. Open the main.tscn scene.  
2. In the **Scene** dock, expand Main \-\> MainVBox \-\> MainArea.  
3. Select the RightPanel node (PanelContainer).  
4. Add a MarginContainer as a child of RightPanel. This will give the content some padding.  
   * In the Inspector for the new MarginContainer, go to **Theme Overrides** \-\> **Constants** and set all four margins (Left, Top, Right, Bottom) to 10\.  
5. Add a VBoxContainer as a child of the MarginContainer. We'll call this DetailVBox.  
6. Add two Label nodes as children of DetailVBox.  
   * Rename the first one to DetailTitle. In its **Inspector**, set its **Text** to "Select an item to view details." Under **Theme Overrides** \-\> **Font Sizes**, set the **Font Size** to 24\.  
   * Rename the second one to DetailDescription. Set its **Text** to "" (empty). Enable **Autowrap** by finding the **Autowrap Mode** property under the Label section and setting it to Word (Smart). This will make long descriptions wrap to the next line.

Your scene tree for the right panel should now look like this:

\- RightPanel (PanelContainer)  
  \- MarginContainer  
    \- DetailVBox (VBoxContainer)  
      \- DetailTitle (Label)  
      \- DetailDescription (Label)

### **2\. Storing Data in Graph Nodes**

To know *what* was clicked, we need to associate our resource data (the CharacterResource, LocationResource, etc.) with the GraphNode we created. We can do this using metadata.

Open the main.gd script and modify the create\_graph\_node function. We will pass the actual resource object to it and store it as metadata.

**Modify main.gd:**

\# ... (keep the top part of the script the same) ...

\# This function clears the graph and populates it from the case\_file resource.  
func display\_case\_data() \-\> void:  
	\# ... (keep the clearing loop) ...  
	  
	var current\_position \= Vector2(100, 100\)  
	var horizontal\_offset \= 400  
	var vertical\_offset \= 200

	\# Display Characters  
	for character in case\_file.characters:  
		\# Pass the whole character resource to the function  
		create\_graph\_node(character, current\_position)  
		current\_position.y \+= vertical\_offset

	\# ... (do the same for Locations and Clues) ...  
	current\_position \= Vector2(100 \+ horizontal\_offset, 100\)  
	for location in case\_file.locations:  
		create\_graph\_node(location, current\_position)  
		current\_position.y \+= vertical\_offset  
	  
	current\_position \= Vector2(100 \+ horizontal\_offset \* 2, 100\)  
	for clue in case\_file.clues:  
		create\_graph\_node(clue, current\_position)  
		current\_position.y \+= vertical\_offset

\# A helper function to create and configure a new GraphNode.  
\# It now accepts a Resource object instead of just a title string.  
func create\_graph\_node(data\_resource: Resource, position: Vector2) \-\> void:  
	var graph\_node \= GraphNode.new()  
	graph\_node.title \= data\_resource.name  
	graph\_node.position\_offset \= position  
	  
	\# Store the actual resource data inside the node's metadata.  
	\# This lets us easily retrieve it later when the node is clicked.  
	graph\_node.set\_meta("data", data\_resource)  
	  
	case\_graph.add\_child(graph\_node)

### **3\. Connecting the Signal**

Godot uses signals to communicate between nodes. The GraphEdit node emits a node\_selected signal whenever a GraphNode inside it is clicked. We need to "connect" this signal to a function in our script.

1. Select the CaseGraph (GraphEdit) node in the **Scene** dock.  
2. Switch to the **Node** tab in the Inspector dock (it's next to the Inspector tab). This tab shows the signals and groups for the selected node.  
3. You will see a list of signals. Find node\_selected(node: Node) and double-click it.  
4. A "Connect a Signal to a Method" window will appear. It should already have the Main node selected. The default method name it suggests will be \_on\_case\_graph\_node\_selected. This is a good, descriptive name.  
5. Click **Connect**. Godot will switch to the main.gd script and automatically add a new function for you.

### **4\. Implementing the Display Logic**

Now, we just need to fill in the code for our new signal-handling function.

**Add this new function to main.gd:**

\# Add these @onready variables at the top with the other one.  
@onready var detail\_title: Label \= %DetailTitle  
@onready var detail\_description: Label \= %DetailDescription

\# This function is called automatically when a node is clicked in the CaseGraph.  
func \_on\_case\_graph\_node\_selected(node: Node) \-\> void:  
	\# Check if the selected node has our data metadata.  
	if node.has\_meta("data"):  
		\# Retrieve the resource we stored earlier.  
		var data \= node.get\_meta("data")  
		  
		\# Update the labels in the right panel with the data.  
		detail\_title.text \= data.name  
		detail\_description.text \= data.description

**Explanation:**

* **@onready var ... \= %Detail...**: Just like with CaseGraph, we get direct references to our new label nodes.  
* **\_on\_case\_graph\_node\_selected(node: Node)**: This is our signal handler. Godot passes the node that was selected (node) as an argument.  
* **if node.has\_meta("data")**: A safety check to make sure we're dealing with a node that we've attached data to.  
* **var data \= node.get\_meta("data")**: We retrieve the CharacterResource (or other resource type) that we stored in step 2\.  
* **detail\_title.text \= data.name**: We access the name and description properties of our resource and assign them to the text property of our labels.

### **5\. Final Test**

Save the script (Ctrl+S) and the scene (Ctrl+S). Press **F5** to run the game one last time.

The case board appears as before. But now, when you click on any of the nodes—"Finch's Workshop," "Nora Vance," or "Overturned Workbench"—the panel on the right will instantly update to show the corresponding title and description you entered in Walkthrough 4\.

Congratulations\! You have successfully built the core framework for a detective game in Godot 4.4.1, from project setup to a fully interactive evidence board.