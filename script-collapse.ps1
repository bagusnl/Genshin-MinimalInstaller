# Game Region List
$urls = @{
    "Genshin-GLB" = "https://sdk-os-static.mihoyo.com/hk4e_global/mdk/launcher/api/resource?channel_id=1&key=gcStgarh&launcher_id=10&sub_channel_id=0"
    "Genshin-CN" = "https://sdk-static.mihoyo.com/hk4e_cn/mdk/launcher/api/resource?channel_id=1&key=eYd89JmJ&launcher_id=18&sub_channel_id=1"
    "HI3-SEA" = "https://sdk-os-static.mihoyo.com/bh3_global/mdk/launcher/api/resource?channel_id=1&key=tEGNtVhN&launcher_id=9&sub_channel_id=1"
    "HI3-GLB" = "https://sdk-os-static.mihoyo.com/bh3_global/mdk/launcher/api/resource?key=dpz65xJ3&channel_id=1&launcher_id=10&sub_channel_id=1"
    "HI3-CN" = "https://bh3-launcher-static.mihoyo.com/bh3_cn/mdk/launcher/api/resource?channel_id=1&key=SyvuPnqL&launcher_id=4&sub_channel_id=1"
}
# HSR does not have decompressed_path
    #"HSR-GLB" = "https://hkrpg-launcher-static.hoyoverse.com/hkrpg_global/mdk/launcher/api/resource?channel_id=1&key=vplOVX8Vn7cwG8yb&launcher_id=35&sub_channel_id=1"
    #"HSR-CN" = "https://api-launcher-static.mihoyo.com/hkrpg_cn/mdk/launcher/api/resource?channel_id=1&key=6KcVuOkbcqjJomjZ&launcher_id=33&sub_channel_id=1"
Write-Host "Minimal Game Installer for miHoYo/Cognosphere Games"
Write-Host "Requires Collapse Launcher!"
Write-Host "Link to download : https://github.com/neon-nyan/Collapse"
Write-Host

# Display a menu to select a Game Region
Write-Host "Select a Game Region:"
$index = 1
$optionKeys = @($urls.Keys | Sort-Object)
$optionKeys | ForEach-Object {
    Write-Host "$index. $_"
    $index++
}

# Prompt the user for their selection
$selection = Read-Host "Enter the number for the game you want to install"
Write-Host

# Check if the selection is valid
if ($selection -ge 1 -and $selection -le $urls.Count) {
    $selectedUrl = $urls[$optionKeys[$selection - 1]]

    try {
        # Send an HTTP request to the selected URL and retrieve the JSON content
        $jsonString = Invoke-RestMethod -Uri $selectedUrl -Method Get

        # Check if the JSON data is valid
        if ($jsonString -match '^[\s\S]*\{.*\}[\s\S]*$') {
            # Decode the JSON string
            $jsonObject = $jsonString

            # Extract values from data.game.latest and data.game.decompressed_path
            $latestVersion = $jsonObject.data.game.latest.version
            $decompressedPath = $jsonObject.data.game.latest.decompressed_path
            $exeName = $jsonObject.data.game.latest.entry

            # Remove .exe extension and add _Data to make game data folder
            $gameName = [System.IO.Path]::GetFileNameWithoutExtension($exeName)
            $gameDataFolderName = $gameName + "_Data"
            $gameDataFolderPath = Join-Path -Path $PWD -ChildPath $gameDataFolderName

            # Output the extracted values
            Write-Host "Game Name: $gameName"
            Write-Host "Latest Game Version: $latestVersion"
            #Write-Host "Decompressed Path: $decompressedPath"
            #Write-Host "Exe name: $exeName"
            #Write-Host "Game Data Folder: $gameDataFolderName"
        }
        else {
            Write-Host "Invalid JSON data received from the URL."
        }

        # Generate config.ini file
        $configFileName = "config.ini"
        $configFilePath = Join-Path -Path $PWD -ChildPath $configFileName
        $configIniContent = @"
[General]
channel=1
game_version=$latestVersion
"@
        $configIniContent | Out-File -FilePath $configFilePath -Encoding utf8

        # Generate game data folder and download necessary files from the url
        try {
            # Generate game data folder
            New-Item -Path $gameDataFolderPath -ItemType Directory | Out-Null

            $gameStreamingAssetsFolder = Join-Path -Path $gameDataFolderPath -ChildPath "StreamingAssets"
            New-Item -Path $gameStreamingAssetsFolder -ItemType Directory | Out-Null

            # Download game exe
            $gameExeUri = $decompressedPath + "/" + $exeName
            $gameExePath = Join-Path -Path $PWD -ChildPath $exeName
            Write-Host "Downloading $exeName""..."
            #Write-Host "Uri: $gameExeUri"
            Invoke-WebRequest -Uri $gameExeUri -OutFile $gameExePath

            # Download app.info file
            $appInfoFile = "app.info"
            $appInfoUri = $decompressedPath + "/" + "$gameDataFolderName" + "/" + "app.info"
            $appInfoPath = Join-Path -Path $gameDataFolderPath -ChildPath $appInfoFile
            Write-Host "Downloading $appInfoFile""..."
            Invoke-WebRequest -Uri $appInfoUri -OutFile $appInfoPath
            }
        catch {
            Write-Host "Error when getting needed files!"
            Write-Host "$_"
        }

        Write-Host "Script completed!"
        Write-Host "Go ahead and set this folder to the respective game that you were selected on Collapse Launcher."
        Write-Host "After that, you can go ahead and do a Game Repair then download everything asked."
    }

    catch {
        Write-Host "Error: $_"
    }
}
else {
    Write-Host "Invalid selection. Please enter a valid number."
}