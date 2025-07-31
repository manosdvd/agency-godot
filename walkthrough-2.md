# **Walkthrough 2: Building the Main UI Layout**

In this section, we will build the foundational layout for the game's main screen. We'll use Godot's powerful container nodes to create a flexible and responsive UI structure.

### **1\. Preparing the Main Scene**

First, let's open the main scene we configured in the last walkthrough.

1. In the **FileSystem** dock (bottom-left), navigate to the scenes/main\_ui/ folder.  
2. Double-click on main.tscn to open it in the editor.  
3. You'll see the scene hierarchy in the **Scene** dock (top-left). It should currently have a single root node of type Node2D.

For user interfaces, it's best to start with a Control node as the root. We will change the root node to a MarginContainer.

1. Right-click the Main node in the Scene dock.  
2. Select **Change Type** from the context menu.  
3. In the "Change Node Type" dialog that appears, search for MarginContainer and select it.  
4. Click the **Change** button. The root node Main is now a MarginContainer.

### **2\. Structuring the Layout with Containers**

Containers automatically arrange their children in a specific way. This is the key to building UIs that adapt to different screen sizes.

#### **A. The Root MarginContainer**

The MarginContainer adds a margin around its children. This will give our UI some nice padding from the edges of the game window.

1. Select the Main (MarginContainer) node.  
2. In the **Inspector** dock (right), find the **Theme Overrides** section and expand it.  
3. Expand the **Constants** section within Theme Overrides.  
4. You will see Margin Bottom, Margin Left, Margin Right, and Margin Top. Set each of these values to 20\.

#### **B. The Main Vertical Box**

Next, we'll add a VBoxContainer (Vertical Box Container) inside our MarginContainer. This container will stack its children vertically.

1. Select the Main node.  
2. Click the **\+** button at the top of the Scene dock (or right-click Main and select **Add Child Node**).  
3. Search for VBoxContainer and click **Create**.  
4. Rename this new node to MainVBox.

#### **C. Header and Main Content Area**

Our UI will have a header at the top and a main content area below it.

1. Select the MainVBox node.  
2. Add a child node of type PanelContainer. Rename it to HeaderPlaceholder. This will be a temporary placeholder for our game's title and main controls.  
3. Again, select MainVBox and add another child node. This time, choose HSplitContainer. Rename it to MainArea. An HSplitContainer allows the user to resize the two panels it holds (one on the left, one on the right).

Your scene tree should now look like this:

\- Main (MarginContainer)  
  \- MainVBox (VBoxContainer)  
    \- HeaderPlaceholder (PanelContainer)  
    \- MainArea (HSplitContainer)

#### **D. Populating the Main Area**

The MainArea will hold the central graph view and the right-side information panel.

1. Select the MainArea (HSplitContainer) node.  
2. Add a child node of type GraphEdit. Rename it CaseGraph. The GraphEdit node is a specialized control for displaying and interacting with graph-like structures, which we'll use for our case board.  
3. Add another child node to MainArea, this time a PanelContainer. Rename it RightPanel. This will hold all the details about selected clues, characters, etc.

### **3\. Making the Layout Responsive**

Right now, the containers don't fill the available space. We need to tell them to expand.

1. Select the MainArea (HSplitContainer) node.  
2. In the **Inspector**, find the **Layout** section and expand it.  
3. Find the **Size Flags** \-\> **Vertical** property and check the **Expand** box. This tells the HSplitContainer to fill all available vertical space inside MainVBox.  
4. Select the CaseGraph node. In its **Layout** properties, set both the **Horizontal** and **Vertical** Size Flags to **Expand Fill**.  
5. Select the RightPanel node and do the same: set both **Horizontal** and **Vertical** Size Flags to **Expand Fill**.

### **4\. Applying the Global Theme**

We have a pre-made theme to give our UI a consistent look.

1. Select the root Main node.  
2. In the **Inspector**, find the **Theme** category (it's separate from Theme Overrides).  
3. In the **FileSystem** dock, navigate to the themes/ folder.  
4. Click and drag main\_theme.tres from the FileSystem dock and drop it into the **Theme** property field in the Inspector.

You should immediately see the editor view change as the theme's styles are applied to the UI elements.

### **5\. Save and Test**

Press **Ctrl+S** to save the scene. Now press **F5** to run the project. You should see a window with your basic layout. The HeaderPlaceholder and RightPanel will appear as styled panels, and you can drag the divider between the CaseGraph area and the RightPanel.

You have now created the fundamental structure of the game's UI. In the next walkthrough, we'll begin creating the custom resource types that will hold our game's data.