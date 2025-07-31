# **Walkthrough 8: Saving and Loading Progress**

A proper investigation takes time. Players need to be able to save their progress—the arrangement of their clue board and the connections they've made—and return to it later. In this walkthrough, we will implement a complete save and load system using Godot's built-in resource management tools.

### **1\. Creating a SaveGame Resource**

First, we need a dedicated data container for our save files. This Resource will store the positions of all the nodes on the graph and the list of connections between them.

1. In the **FileSystem** dock, right-click the scripts/resources/ folder.  
2. Select **Create New** \-\> **Script...**.  
3. In the dialog:  
   * **Inherits**: Resource  
   * **Path**: res://scripts/resources/save\_game\_resource.gd  
4. Click **Create** and replace the default content with this:

@tool  
extends Resource  
class\_name SaveGameResource

\#\# An array of dictionaries, where each dictionary holds data for a single node.  
@export var node\_data: Array\[Dictionary\]

\#\# An array of dictionaries for the connections.  
@export var connection\_data: Array\[Dictionary\]

This simple resource defines two arrays that will hold all the data we need to perfectly rebuild the GraphEdit state.

### **2\. Adding Save/Load UI Buttons**

Let's add buttons to the UI so the player can trigger the save/load actions.

1. Open the main.tscn scene.  
2. In the **Scene** dock, find the HeaderPlaceholder node. We'll replace this with a proper header.  
3. Right-click HeaderPlaceholder and select **Change Type**. Change it to HBoxContainer. Rename it to Header.  
4. Select the Header node. Add a Label as a child and set its **Text** to "The Agency". Set its **Layout** \-\> **Size Flags** \-\> **Horizontal** to **Expand Fill**.  
5. Add a Button as a child of Header. Rename it SaveButton and set its **Text** to "Save".  
6. Add another Button as a child of Header. Rename it LoadButton and set its **Text** to "Load".

### **3\. Refactoring for Stable Save/Load**

To reliably save and load connections, we need a consistent way to identify each node. A node's default name (like @GraphNode@5) can change each time the game runs. We will modify our create\_graph\_node function to assign a stable, unique name to each node based on its underlying data resource.

**Modify the create\_graph\_node function in main.gd:**

\# Modify the function to set a unique, stable name for the node.  
func create\_graph\_node(data\_resource: Resource, position: Vector2) \-\> void:  
	var graph\_node \= GraphNode.new()  
	  
	\# Use the resource's own path as its unique identifier.  
	\# The path is always unique within a project.  
	graph\_node.name \= data\_resource.resource\_path.replace("/", "\_")  
	  
	graph\_node.title \= data\_resource.name  
	graph\_node.position\_offset \= position  
	graph\_node.set\_meta("data", data\_resource)  
	graph\_node.set\_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)  
	  
	case\_graph.add\_child(graph\_node)

By setting the name property to the resource's file path (with slashes replaced to be safe), we now have a unique ID for each node that will be the same every time we run the game.

### **4\. Implementing the Save/Load Logic**

Now we'll write the core logic. Connect the pressed signals from our new buttons to the Main script.

1. Select SaveButton, go to the **Node** tab, and connect the pressed() signal to a new \_on\_save\_button\_pressed function.  
2. Select LoadButton, go to the **Node** tab, and connect the pressed() signal to a new \_on\_load\_button\_pressed function.

**Add the following code to main.gd:**

\# \--- ADD AT THE TOP OF THE SCRIPT \---  
const SAVE\_PATH \= "user://case\_01.tres"

\# \--- ADD THE NEW FUNCTIONS AT THE BOTTOM \---

func \_on\_save\_button\_pressed() \-\> void:  
	var save\_game \= SaveGameResource.new()  
	  
	\# Save node positions and data paths  
	for node in case\_graph.get\_children():  
		if node is GraphNode:  
			var data\_resource: Resource \= node.get\_meta("data")  
			save\_game.node\_data.append({  
				"path": data\_resource.resource\_path,  
				"position\_x": node.position\_offset.x,  
				"position\_y": node.position\_offset.y  
			})  
			  
	\# Save connections  
	for connection in case\_graph.get\_connection\_list():  
		save\_game.connection\_data.append({  
			"from": connection.from\_node,  
			"to": connection.to\_node  
		})  
	  
	\# Save the resource to a file  
	var error \= ResourceSaver.save(save\_game, SAVE\_PATH)  
	if error \== OK:  
		print("Game saved successfully\!")  
	else:  
		print\_err("Error saving game.")

func \_on\_load\_button\_pressed() \-\> void:  
	if not FileAccess.file\_exists(SAVE\_PATH):  
		print("No save file found.")  
		return

	var save\_game: SaveGameResource \= ResourceLoader.load(SAVE\_PATH)  
	  
	\# Clear the current board  
	for connection in case\_graph.get\_connection\_list():  
		case\_graph.disconnect\_node(connection.from\_node, connection.from\_port, connection.to\_node, connection.to\_port)  
	for node in case\_graph.get\_children():  
		if node is GraphNode:  
			node.queue\_free()  
			  
	\# Wait one frame for nodes to be fully removed before rebuilding  
	await get\_tree().process\_frame  
	  
	\# Rebuild the graph from save data  
	for node\_info in save\_game.node\_data:  
		var data\_resource: Resource \= load(node\_info.path)  
		var position \= Vector2(node\_info.position\_x, node\_info.position\_y)  
		create\_graph\_node(data\_resource, position)  
		  
	\# Re-establish connections  
	for connection\_info in save\_game.connection\_data:  
		\# We assume all connections are from port 0 to port 0  
		case\_graph.connect\_node(connection\_info.from, 0, connection\_info.to, 0\)  
		  
	print("Game loaded\!")

**Explanation:**

* **SAVE\_PATH**: We define a constant for our save file location. The user:// directory is Godot's special folder for storing user-specific data, which is the correct place for save files.  
* **Save Logic**: We create a new SaveGameResource, loop through all the GraphNodes to store their data path and position, loop through all connections, and finally use ResourceSaver.save() to write it all to a file.  
* **Load Logic**: We first check if a save file exists. Then we load it with ResourceLoader. The crucial part is clearing the board completely before rebuilding it from the saved data. We use await get\_tree().process\_frame to ensure the old nodes are gone before we add the new ones, preventing potential conflicts. Finally, we recreate the nodes and then the connections.

### **5\. Final Test**

Save everything and run the game (F5). Move the nodes around on your board, and create a few connections. Click the "Save" button. Now, move the nodes again and break the connections. Finally, click "Load." The board should snap back to the exact state it was in when you saved.

You now have a fully functional save/load system, making your detective game feel much more complete.