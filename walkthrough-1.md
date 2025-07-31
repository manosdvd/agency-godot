# **Walkthrough 1: Getting Started and Project Setup**

This walkthrough will guide you through the initial setup of the "Agency" project in the Godot Engine, version 4.4.1. We will cover opening the project, exploring the editor layout, and making some initial configurations to ensure a smooth development process.

### **1\. Launching the Godot Project Manager**

First, you need to open the Godot Engine. When you launch Godot, you are first greeted with the **Project Manager**. This window lists all of your Godot projects.

If this is your first time using Godot, this list will be empty. We need to add our "Agency" project to this list.4

### **2\. Importing the "Agency" Project**

The project files you have are ready to be opened by Godot.

1. In the Project Manager window, click the **Import** button. This will open a file dialog.  
2. Navigate to the directory where you've stored the agency-godot files.  
3. Select the agency subfolder, which contains the project.godot file.  
4. After selecting the folder, Godot will automatically detect the project.godot file. Click the **Import & Edit** button.

Godot will then proceed to open the project in the main editor window. This might take a moment as it imports all the assets for the first time.

### **3\. Exploring the Godot Editor**

Once the project is open, you will be presented with the main Godot editor interface. Let's take a moment to familiarize ourselves with the key components:

* **Scene Dock (Top Left):** This is where you'll see the tree structure of the nodes in your currently opened scene. Nodes are the fundamental building blocks in Godot.  
* **FileSystem Dock (Bottom Left):** This dock shows your project's file structure, similar to a file explorer. You can see all the folders like scenes, scripts, and assets here. The res:// path is your project's root directory.  
* **Main Viewport (Center):** This is the largest area of the editor. It's where you will visually construct your game. You can switch between 2D, 3D, and Script views using the tabs at the top of this area. By default, it will likely open to the 3D view.  
* **Inspector Dock (Right):** When you select a node in the Scene dock, its properties will be displayed here. This is where you will configure your nodes, change their colors, text, and other attributes.  
* **Toolbar (Top):** Contains options for running your game, managing project settings, and more.

### **4\. Setting the Main Scene**

Godot needs to know which scene to run when you start the game.

1. Go to the **Project** menu in the top toolbar and select **Project Settings...**.  
2. A new window will open. Make sure you are on the **General** tab.  
3. Under the **Application** \-\> **Run** category on the left, you will find the **Main Scene** property.  
4. Click the folder icon next to the **Main Scene** field.  
5. A file dialog will appear. Navigate to scenes/main\_ui/ and select main.tscn. Click **Open**.  
6. You should now see the path res://scenes/main\_ui/main.tscn in the **Main Scene** field.  
7. Close the Project Settings window.

Now, when you press the **Play** button (or F5), Godot will launch the main.tscn scene.

### **5\. Running the Project**

Let's test it out.

* Click the **Play** button in the top-right corner of the editor (it looks like a "play" icon).

A new window should appear, displaying the current state of the main.tscn scene. It will likely be a plain gray screen, as we haven't added any visible elements to it yet. This is expected. To close the game window, you can press Alt+F4 or click the close button on the window's title bar.

You have now successfully set up the project in Godot 4.4.1 and confirmed that it can run. In the next walkthrough, we will start building the user interface.