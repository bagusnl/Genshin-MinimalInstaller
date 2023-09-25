# Genshin-MinimalInstaller

A new way to install Genshin Impact.

This script will install Genshin Impact without its launcher. It downloads each files individually (whopping 12K+ files) meaning it doesn't have to download the zip package first (except Audio) package and only requiring about 90GB (~60GB for the game and ~30GB for audio package) of free space. This is also useful for someone with bad internet as when download corruption occurred, it will retry to download smaller file instead of redownloading an (or multiple) zip segments.

Advantages (for standalone script):
 - Does not require 120GB free space!
 - Multithreaded file download (using + aria2c)
 - All downloaded file is verified for corruption
 - Bad internet friendly

### TODO
 - Make Audio package installation be done before base game files to help more with free space requirements. Currently its not possible to download Audio package files individually due to it not being served as individual files.

## How to use 
### Standalone script
1. Go to folder you want to install Genshin on (empty folder is HIGHLY recommended)
2. Hold Shift and do a right click on the empty space
3. Press "Open PowerShell window here"
4. Copy and paste this code to the PowerShell window
    > ```powershell
    > Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex "&{$((New-Object System.Net.WebClient).DownloadString('https://github.com/bagusnl/Genshin-MinimalInstaller/raw/main/script-standalone.ps1'))} global"
    >```
5. Run the script by pressing enter
6. Follow the instruction inside the window

#### Notes:
If you had a problem that requires you to restart or interrupt the process, just re-run the script and it will continue from the last file you downloaded.
You can add the game to both Genshin's Official Launcher or custom launcher (like Collapse Launcher) if you prefer to do so.

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
   >```
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

# How to update game ?
It is recommended to use the zip method (look on technical-channel channel on Genshin Impact Discord server), or using launcher.

If you use Collapse Launcher, you can also change the game_version string inside the config.ini to the current updated version to simulate updated installation, then use the Game Repair to update all the files and assets to the current version. NOTE that this will only works AFTER the patch is dropped (after maintenance is done).

# Disclaimer
This project is **NOT** affiliated with miHoYo (miHoYo Co., Ltd.) or HoYoverse (COGNOSPHERE PTE. LTD.) in any way. Genshin Impact and Honkai Impact are registered trademark of miHoYo Co., Ltd. under USPTO SN 88985076/97256855 and 87814281 respectively.

# Special Thanks
- aria2c by Tatsuhiro Tsujikawa (tatsuhiro-t) https://github.com/aria2/aria2
- Collapse Launcher project by neon-nyan https://github.com/neon-nyan/Collapse/
- MadeBaruna for reference on how to make a PowerShell script runs from internet (Shout out Paimon.moe project)
