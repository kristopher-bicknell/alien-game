# Alien Game
This game does not have an official title yet, but it has the working title Alien Game.

As of now, all that it is, is a world generation simulator. You can generate terrain, save it, load it from a file, and, of course, walk around on it.
# Controls

> [!NOTE] Note about the controls
> The controls currently suck. I do not like them, and they will be changing.
>  *If you want to help me make them suck less, feel free to provide feedback!*

Focus the mouse on the window using the \[Middle Mouse Button]. Move the mouse to move the camera. Use \[W] \[A] \[S] \[D] keys to move your player. Press \[Spacebar] to jump a fixed (and slightly too high) height.

There are a few debugging keys available, as indicated on the screen at runtime. Here's a greater overview into what each of them do:
### \[9] Generate new map
>To prevent issues, the player will be moved back to the spawn platform. 

Clear the currently loaded map and will randomly generate a new map. The map generation algorithm is based on multiple noise maps with random seeds. 
### \[0] Clear map data
>To prevent issues, the player will be moved back to the spawn platform. 

Clear the currently loaded map, resulting in an empty world (minus your starting platform). 
### \[-] Save current map
Saves the currently loaded map to a file called `world.dat`. Map data is saved using a [run-length encoding algorithm](https://www.geeksforgeeks.org/dsa/run-length-encoding/) and the save file should be approximately 200-300 kB. The save file location is the default `user://` directory for Godot projects.
### \[=] Load map from file
>To prevent issues, the player will be moved back to the spawn platform. 

Clears the currently loaded map and loads a map created from the data saved to `world.dat`. 
### \[\\] Reset player to spawn platform
Resets the player's position to the spawn platform. The current cave generation algorithm is very buggy, and it tends to create large chasms that you can easily get stuck in. If you fall off the edge of the map, the death plane will automatically respawn you on the spawn platform. 
# Messing with the world generation parameters
I don't plan on customizable worldgen being a part of the finished project, since that's not the point of the game, but it is *technically* doable. Go to `main.tscn`, and in the node `WorldGen` there is a `GenerationSettings` resource file. Anything that uses world generation sources the rules from this file. 

**A couple notes:**
- Make sure the chunk size is divisible by the map radius. I haven't tested what happens when it isn't.
- Save file data doesn't encode any information about the `GenerationSettings` resource. This is because world generation settings are meant to remain static between worlds. If you load a file that was created with different world generation settings, unexpected results may occur. 
# Credits / See also
- World generation uses a lot of code from [HexagonalMapGodot by ForlornU](https://github.com/ForlornU/HexagonalMapGodot/), mainly for the procedural mesh generation of hexagonal terrain
