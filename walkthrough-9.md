# **Walkthrough 9: Exporting Your Game**

You've built an interactive detective board, and now it's time to share your creation with the world. This walkthrough will guide you through the process of exporting your "Agency" project as a standalone application for Windows.

### **1\. Installing Export Templates**

Before you can export your game, you need to install Godot's **export templates**. These are pre-compiled, optimized versions of the engine without the editor, which are used to build the final executable file. It's crucial that the template version exactly matches your Godot editor version (4.4.1).

1. In the Godot editor, go to the **Project** menu in the top toolbar.  
2. Select **Export...**.  
3. The **Export** window will open. At the top, you will likely see a message in red stating, "No export templates found at the expected location."  
4. To the right of this message, click the link that says **Manage Export Templates**.  
5. The **Export Template Manager** window will appear. It should automatically show your current version (4.4.1.stable).  
6. Click the **Download and Install** button. Godot will download the templates (it's a large file, so it may take a few moments) and install them into the correct engine configuration directory.  
7. Once the process is complete, you'll see a message confirming the installation. You can now close the Export Template Manager.

### **2\. Creating an Export Preset**

An export preset defines all the settings for a specific platform (like Windows, Linux, or macOS).

1. With the **Export** window still open, click the **Add...** button at the top.  
2. A dropdown menu will appear with a list of platforms. Select **Windows Desktop**.  
3. A new "Windows Desktop" preset will now appear in the list. All the default settings are usually sufficient for a basic export.

### **3\. Customizing the Export (Icon and Details)**

Let's give our exported game a proper icon and file information.

1. In the **Export** window, make sure your "Windows Desktop" preset is selected.  
2. On the right side, you'll see a list of options. Find the **Application** category.  
   * **Icon**: The default Godot icon is used. To set your own, you would first import an .ico file into your project, then drag it to this field. For now, the default is fine.  
   * **File Version** & **Product Version**: You can set these to 1.0.0.  
   * **Product Name**: Set this to Agency.  
   * **Company Name**: Enter your name or studio name.

### **4\. Exporting the Project**

Now you're ready to create the executable file.

1. At the bottom of the **Export** window, click the **Export Project** button.  
2. A file dialog will open, asking you where to save the exported game.  
3. It's best practice to create a new, separate folder for your exported builds. For example, create a folder named builds outside of your project directory.  
4. Inside the builds folder, create another folder named agency-windows.  
5. Navigate into the agency-windows folder. For the **File name**, enter Agency.exe.  
6. Ensure the **Export with debug** checkbox is **unchecked**. This will create a smaller, optimized release version of your game.  
7. Click **Save**.

Godot will now build your project. This process involves copying the engine executable, packing all your project's assets (.tscn, .gd, .tres files, etc.) into a .pck file, and putting them together in the folder you specified.

### **5\. Running Your Game**

Once the export process is finished (it's usually very quick for a small project), navigate to the output folder you created (builds/agency-windows).

Inside, you will find:

* **Agency.exe**: This is your game's executable file. Double-click it to run your game outside of the Godot editor.  
* **Agency.pck**: This file contains all of your game's data. The .exe file needs this .pck file to be in the same directory to run.

You have now successfully exported your project\! You can zip the agency-windows folder and distribute it to anyone with a Windows computer to play. This completes the development cycle from initial concept to a distributable product.