# Walkthrough 10: World Builder Foundation

We're shifting gears to build the tool that will create the very worlds our cases take place in. This is the foundation of everything. We'll create the main scene for the World Builder and the core data resource that will hold all the information about our game world.

### 1\. Create the World Builder Main Scene

First, let's create the main scene for our new tool.

1.  **Create a new scene.** In the Godot editor, go to `Scene > New Scene`.
    
2.  Choose **User Interface** as the root node. This will create a `Control` node.
    
3.  Rename the root node to `WorldBuilder`.
    
4.  Save the scene as `agency/scenes/main_ui/world_builder.tscn`.
    

### 2\. Create the World Resource

We need a central place to store all the data for a world. We'll create a new `Resource` script for this.

1.  In the `FileSystem` dock, right-click on the `agency/scripts/resources/` folder.
    
2.  Select `Create New > Script`.
    
3.  Name the script `world_resource.gd`.
    
4.  Make it inherit from `Resource`.
    
5.  Click `Create`.
    

Now, open `agency/scripts/resources/world_resource.gd` and add the following code. This script will define the structure of our game world.

### 3\. Update Project Settings

We need to tell Godot to run our new `world_builder.tscn` scene when we press the play button.

1.  Go to `Project > Project Settings`.
    
2.  In the `Application > Run` section, set the `Main Scene` to `agency/scenes/main_ui/world_builder.tscn`.
    
3.  Close the Project Settings window.
    

Now, when you run the project, you'll see a blank screen, which is our World Builder's main scene. In the next walkthrough, we'll start adding UI elements to it.





