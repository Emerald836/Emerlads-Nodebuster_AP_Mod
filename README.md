# Nodebuster AP Mod
This is a Mod for Nodebuster that provides integration for Archipelago Multi World
* [Releases](https://github.com/Emerald836/Emerlads-Nodebuster_AP_Mod/releases)
### Things to note
* This mod prevents you from being able to play normally. by removing the mod from the mod folder it should revert and allow you to play normally.
* While playing this mod it is highly recommended to choose new save when you join an ap world. if you do not want to lose your save I would recommend creating a backup.

# Gameplay
After generating a seed, every upgrade in the upgrade tree scene will be different. Instead of the first damage upgrade giving you a damage upgrade. It could instead give you a health upgrade.

Locations(Checks) are the upgrade nodes in the upgrade tree, Milestone rewards, Boss Drops, and CryptoMine Levels.

### Recommended Software
* QOL Mods.
    * I would highly recommend using a QOL mod just to make your life easier. As this game while normally not long, does have over 500 checks on the standard settings. And with progression being so broken up due to randomization it can easily make the game a lot longer.
    * If you can not find a mod for Nodebuster you can find one [Here](https://github.com/Emerald836/Emerlad-Nodebuster-QOL-Mod/releases)

# Installation
### Required Software
* A legal copy of Nodebuster.
    * Steam.
    * Windows.
* Download the Godot Mod Loader from this [Github](https://github.com/GodotModding/godot-mod-loader/pull/533)
    * We use this version due to the main branch not working with Nodebuster.
* Download the [Archipelago Mod](https://github.com/Emerald836/Emerlads-Nodebuster_AP_Mod/releases)

## Installing Mod Loader and Mod
1. After downloading the Mod Loader from [here](https://github.com/GodotModding/godot-mod-loader/pull/533). Extract the addons folder from the zip and put it in your Nodebuster files right next to the Executable.
 * This can be found by right clicking on your Nodebuster game in steam and clicking browse local files.
2. Go back to steam and go to the properties window by right clicking your Nodebuster game and clicking properties.
3. After the window opens find launch options and put "--script addons/mod_loader/mod_loader_setup.gd"(remove quotes) in the launch options field. Then open Nodebuster once.
3. After you opened the game go back to the properties window and remove what we put in the launch options field.
4. Go back to the Nodebuster local files. and create a folder named "mods".
5. Insert the ZIP file of the archipelago mod found [here](https://github.com/Emerald836/Emerlads-Nodebuster_AP_Mod/releases) into the mods folder.
 * Do not unzip the mod file as the mod loader requires for it to be zipped.
6. Open up Nodebuster once more and the game should ask you to restart the game. Click yes. After restarting the game the mod will be installed.

### What to do if the Mod Loader doesn't install correctly
* This can happen due to either the wrong version of the Mod loader was installed or the launch options field wasn't filled correctly.

1. Check the launch options field in the properties window of the game. If you still have what we put back in step 3 of setup. Remove it and try starting the game again.

2. Make sure you downloaded the Mod Loader from [Here](https://github.com/GodotModding/godot-mod-loader/pull/533). This is the version that I was able to get working. any other version I was unable to get working.
  * More information on the Godot Mod Loader can be found on the [Wiki](https://wiki.godotmodding.com)

# Joining an Archipelago Game in Nodebuster
1. Start the game after installing all necessary mods.
2. In the main menu you should see a Connect button instead of a new game, and cotinue game button.
3. Click said Connect button.
4. Input the correct information in the correct fields. (ie. "archipelago:12993" in the address slot.).
5. Click Connect and wait a tiny bit.
 * If it takes more then a min to connect then check your input fields to make sure everything is correct.
6. After the game connects to archipelago. It will either take you straight to the upgrade tree scene. Or if you have a save file that was already connected to the server address you are using. It will instead ask if you want to use the aforementioned save file or no.
7. Enjoy!
