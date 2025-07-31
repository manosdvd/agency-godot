Walkthrough 4: Populating the Case File
Now that we have our data structures (Resource scripts) and an empty case file (case_01.tres), it's time to breathe life into our mystery. In this walkthrough, we will populate the case file with all the necessary starting information, creating the characters, locations, and clues that the player will investigate.
1. Opening the Case File
In the FileSystem dock, navigate to the cases/ folder.
Click on case_01.tres to select it.
The Inspector dock on the right will now show the properties of our CaseResource: "Case Name," "Description," and the empty arrays for "Characters," "Locations," and "Clues."
2. Filling in the Basic Case Details
Let's start with the easy part.
In the Inspector, find the Case Name property and leave it as "The Missing Automaton".
For the Description property, enter the following text:
"A renowned gearmancer, Alistair Finch, has been found dead in his workshop. His most prized creation, a one-of-a-kind automaton, is missing. Foul play is suspected."
3. Creating Sub-Resources
This is where the power of Godot's resource system shines. We can create and define our CharacterResource, LocationResource, and other resources directly inside our main case_01.tres file.
A. Adding Characters
In the Inspector, find the Characters property. It currently says "Array[CharacterResource] (size 0)".
Click on "Array[CharacterResource] (size 0)" to expand it.
Set the Size to 3. You will now see three empty slots: Element 0, Element 1, and Element 2.
Click on the dropdown arrow next to Element 0 (which currently says [empty]) and select New CharacterResource. The slot will now contain a new, embedded CharacterResource.
Click on the newly created CharacterResource to expand its properties right there in the Inspector.
Fill in the properties for the first character:
Name: Alistair Finch
Description: A master gearmancer and the victim. Known for his reclusive nature and groundbreaking work in automaton intelligence.
Faction: Leave [empty] for now. We will create factions later.
Repeat steps 4-6 for the other two characters with the following data:
Character 2 (Element 1):
Name: Eleonora "Nora" Vance
Description: Finch's ambitious and talented apprentice. She reported him missing.
Character 3 (Element 2):
Name: Silas "The Fixer" Croft
Description: A shadowy figure from the industrial underbelly, known for dealing in rare and stolen arcane technology.
B. Adding Locations
Now, let's do the same for the Locations array.
Find the Locations property in the Inspector.
Set its Size to 2.
For Element 0, select New LocationResource and fill in its properties:
Name: Finch's Workshop
Description: A cluttered, multi-level workshop filled with half-finished inventions, blueprints, and arcane tools. The scene of the crime.
District: Leave [empty].
For Element 1, select New LocationResource and fill in its properties:
Name: The Gilded Cog
Description: An underground tavern and black market hub frequented by tech-mercenaries and smugglers.
District: Leave [empty].
C. Adding a Starting Clue
Finally, let's add one initial clue to get the investigation started.
Find the Clues property.
Set its Size to 1.
For Element 0, select New ClueResource.
Fill in its properties:
Name: Overturned Workbench
Description: The main workbench shows signs of a struggle. Blueprints are scattered, and a faint, unfamiliar energy signature lingers in the air.
4. Saving Your Work
After entering all this data, it's crucial to save it. Godot does not always auto-save resource changes.
Go to the main menu at the top of the editor and select File -> Save All. You can also press Ctrl+Shift+S.
You now have a complete, self-contained case file with all the initial data needed to start the game. All this information—characters, descriptions, locations—is neatly packed into the case_01.tres file. In the next walkthrough, we'll start writing the code to load this file and display the information in our UI.
