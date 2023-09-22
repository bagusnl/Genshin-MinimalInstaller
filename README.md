# Genshin-MinimalInstaller

A new way to install Genshin Impact
Advantages (for standalone script):
 - Does not require 120GB free space!
 - Multithreaded file download (using + aria2c)
 - All downloaded file is verified for corruption

## How to use 
### Standalone script
1. Go to folder you want to install Genshin on (empty folder is HIGHLY recommended)
2. Hold Shift and do a right click on the empty space
3. Press "Open PowerShell window here"
4. Copy and paste this code to the PowerShell window
    > ```powershell
    > Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex "&{$((New-Object System.Net.WebClient).DownloadString('https://github.com/bagusnl/Genshin-MinimalInstaller/raw/main/script-standalone.ps1'))} global"
    >    ```
5. Run the script by pressing enter
6. Follow the instruction inside the window

#### Notes:
If you had a problem that requires you to restart or interrupt the process, just re-run the script and it will continue from the last file you downloaded.

### Collapse script
> This is much smaller script intended to be used with [Collapse Launcher](https://github.com/neon-nyan/Collapse/) as the file assets downloaded and the launcher.
> If you want to use or intended to use Collapse to manage the game, use this script instead.
> Requires Collapse Launcher version 1.72.0+

1. Go to folder you want to install Genshin on (empty folder is HIGHLY recommended)
2. Hold Shift and do a right click on the empty space
3. Press "Open PowerShell window here"
4. Copy and paste this code to the PowerShell window
   > ```powershell
   > Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex "&{$((New-Object System.Net.WebClient).DownloadString('https://github.com/bagusnl/Genshin-MinimalInstaller/raw/main/script-collapse.ps1'))} global"
   >    ```
5. Run the script by pressing enter
6. Follow the instruction inside the window
7. Run Collapse Launcher and press "Locate Game"
8. Once Collapse detects Genshin is installed, directly go to "Game Repair" page and press "Quick Check"
9. It will detects bunch of file missing, press "Fix Game"
10. Let it download until it finish

#### Notes:
- With this method, Collapse will download Japanese voice language by default. If you prefer other language, you can change it in audio_lang_14 file.
  1. Go to GenshinImpact_Data/Persistent folder
  2. Make a file named `audio_lang_14` (make sure it doesn't have an extension and its case-sensitive!)
  3. Use one or more combination of possible voice languages from here
     > ```powershell
     > English(US)
     > Japanese
     > Chinese
     > Korean
     > ```
  4. Run the Game Repair sequence in Collapse
- You can always stops the Game Repair process anytime and re-run it once you're ready. But note that the game will always crash or have problems before all the files is downloaded.

# Special Thanks
- aria2c by Tatsuhiro Tsujikawa (tatsuhiro-t) https://github.com/aria2/aria2
- Collapse Launcher project by neon-nyan https://github.com/neon-nyan/Collapse/
- MadeBaruna for reference on how to make a PowerShell script runs from internet (Shout out Paimon.moe project)