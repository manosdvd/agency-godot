# **Walkthrough 7: Connecting the Clues**

A detective's corkboard isn't complete without red string connecting the clues. In this walkthrough, we will implement the ability for the player to draw and remove connections between the nodes on the GraphEdit board. This involves enabling connection "slots" on our nodes and then using signals to handle the player's actions.

### **1\. Enabling Connection Slots on Nodes**

For GraphNodes to be connectable, they need to have defined connection points, or "slots." We will modify our create\_graph\_node function to add a single connection slot on both the left and right sides of every node we create.

**Modify the create\_graph\_node function in main.gd:**

\# A helper function to create and configure a new GraphNode.  
func create\_graph\_node(data\_resource: Resource, position: Vector2) \-\> void:  
	var graph\_node \= GraphNode.new()  
	graph\_node.title \= data\_resource.name  
	graph\_node.position\_offset \= position  
	  
	\# Store the actual resource data inside the node's metadata.  
	graph\_node.set\_meta("data", data\_resource)  
	  
	\# \--- NEW CODE \---  
	\# Configure the node to have connection slots.  
	\# This enables one slot on the left (port 0\) and one on the right (port 0).  
	\# The type is set to 0 (a generic type) and the color is the default theme color.  
	graph\_node.set\_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)  
	\# \--- END NEW CODE \---  
	  
	case\_graph.add\_child(graph\_node)

Explanation:  
The set\_slot function configures a slot at a given index (we're using index 0). The arguments are: (index, enable\_left, type\_left, color\_left, enable\_right, type\_right, color\_right). By setting enable\_left and enable\_right to true, we create the visible connection points on the node.  
Save the script. If you run the game now (F5), you'll see small circles on the left and right edges of each node. You can click and drag from these circles, but they won't connect yet.

### **2\. Handling Connection and Disconnection Requests**

The GraphEdit node handles user input for connections and emits signals when the player tries to create or break a link. We need to connect to these signals.

1. Select the CaseGraph (GraphEdit) node in the **Scene** dock.  
2. Go to the **Node** tab (next to the Inspector).  
3. Find and double-click the connection\_request(from\_node: StringName, from\_port: int, to\_node: StringName, to\_port: int) signal. Connect it to a new method in the Main node called \_on\_case\_graph\_connection\_request.  
4. Find and double-click the disconnection\_request(from\_node: StringName, from\_port: int, to\_node: StringName, to\_port: int) signal. Connect it to a new method called \_on\_case\_graph\_disconnection\_request.

Godot will add two new functions to your main.gd script.

### **3\. Implementing the Connection Logic**

Now, fill in the code for these new functions. When a connection is requested, we simply tell the GraphEdit to complete it. When a disconnection is requested, we tell it to break the link.

**Add these new functions to main.gd:**

\# Called when the player drags a line from one node to another.  
func \_on\_case\_graph\_connection\_request(from\_node: StringName, from\_port: int, to\_node: StringName, to\_port: int) \-\> void:  
	\# The arguments give us the names of the nodes and the port numbers.  
	\# We simply approve the connection.  
	case\_graph.connect\_node(from\_node, from\_port, to\_node, to\_port)

\# Called when the player right-clicks a connection.  
func \_on\_case\_graph\_disconnection\_request(from\_node: StringName, from\_port: int, to\_node: StringName, to\_port: int) \-\> void:  
	\# We approve the disconnection.  
	case\_graph.disconnect\_node(from\_node, from\_port, to\_node, to\_port)

### **4\. Test the Interactivity**

Save the script and run the game (F5).

You can now click and drag from a slot on one node to a slot on another to create a connection line. To remove a connection, right-click on either of the connected slots.

You have now implemented the core "red string" mechanic of your detective board\! This allows players to visually organize their thoughts and theories by linking related pieces of information. The next steps from here could involve adding logic to check if a player's connection is correct, or saving the state of the board.