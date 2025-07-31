# **Walkthrough 3: Creating Data Resources**

In Godot, a Resource is a special type of object designed to hold data. They are ideal for creating templates for things like items, characters, or, in our case, clues and case files. We can save resources as individual files, making our data modular and easy to manage.

This walkthrough will guide you through creating the various custom resource scripts that will define all the data for our detective game.

### **1\. Understanding Custom Resources**

By creating a script that inherits from the Resource class, we can define our own custom data containers. We can then create multiple instances of these resources, each with different data, directly from the Godot editor's FileSystem dock.

The @tool annotation at the top of a script tells Godot to run the script in the editor. This is essential for custom resources, as it allows the editor to understand and display the custom properties we define.

### **2\. Creating the Base CaseResource**

First, we'll create the main resource that will hold all the information for a single case.

1. In the **FileSystem** dock, right-click on the scripts/resources/ folder.  
2. Select **Create New** \-\> **Script...**.  
3. A "Create Script" dialog will appear.  
   * For **Inherits**, type Resource and select it from the list.  
   * For **Path**, ensure it's pointing to res://scripts/resources/case\_resource.gd.  
   * Click **Create**.  
4. The script editor will open with your new file. Replace the default content with the following code:

@tool  
extends Resource  
class\_name CaseResource

\#\# The official name of the case.  
@export var case\_name: String \= "The Missing Automaton"

\#\# A brief description of the case's premise.  
@export\_multiline var description: String \= ""

\#\# An array to hold all the characters involved in the case.  
@export var characters: Array\[CharacterResource\]

\#\# An array to hold all the locations relevant to the case.  
@export var locations: Array\[LocationResource\]

\#\# An array to hold miscellaneous clues.  
@export var clues: Array\[ClueResource\]

**Explanation:**

* @tool: Makes this script run in the editor.  
* extends Resource: Specifies that this script is a type of Resource.  
* class\_name CaseResource: Registers "CaseResource" as a new type within Godot, making it available in the editor.  
* @export: This keyword is powerful. It makes the variable (case\_name, description, etc.) visible and editable in the **Inspector** when we select a CaseResource file.  
* Array\[CharacterResource\]: This is a typed array. It tells Godot that the characters array can only hold CharacterResource objects, which we will define next. This provides better code safety and autocompletion.

### **3\. Creating the Other Resource Scripts**

Now, repeat the process for all the other data types we need. The project already contains these scripts, so your main task is to understand their structure. Open each of the following files from scripts/resources/ and examine their contents. Notice how they all follow the same pattern: @tool, extends Resource, class\_name, and @export variables.

* **character\_resource.gd**: For storing data about individual characters (e.g., their name, faction).  
* **clue\_resource.gd**: A general-purpose resource for simple clues.  
* **district\_resource.gd**: Defines a district in the city.  
* **faction\_resource.gd**: Defines a faction or organization.  
* **interview\_resource.gd**: To hold the details of an interview with a character.  
* **item\_resource.gd**: For physical items that can be found.  
* **location\_resource.gd**: For specific locations within a district.

Feel free to open these scripts and look at the properties defined in each one. For example, location\_resource.gd will have an @export var district: DistrictResource property, linking a location to its district. This ability to link resources together is what will form the web of connections in our case.

### **4\. Creating a Test Case File**

Now that we've defined all our data templates, let's create an actual case file using them.

1. In the **FileSystem** dock, create a new folder at the root level called cases.  
2. Right-click the new cases folder.  
3. Select **Create New** \-\> **Resource...**.  
4. A dialog will open, listing all available resource types. Search for and select **CaseResource**.  
5. Save the file as case\_01.tres.  
6. Now, click on your newly created case\_01.tres file in the FileSystem.  
7. The **Inspector** will now display all the properties we defined with @export in case\_resource.gd\!

You can see fields for "Case Name," "Description," and arrays for "Characters," "Locations," and "Clues." For now, these arrays will be empty. In the next walkthrough, we will populate these arrays with data.

You have now successfully defined the entire data structure for the game. This data-driven approach will make it easy to create new cases and content without having to write new code.