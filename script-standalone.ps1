Write-Host Minimal installer for Genshin Impact
$regions = @{
    "Genshin-GLB" = "https://sdk-os-static.mihoyo.com/hk4e_global/mdk/launcher/api/resource?channel_id=1&key=gcStgarh&launcher_id=10&sub_channel_id=0"
    "Genshin-CN" = "https://sdk-static.mihoyo.com/hk4e_cn/mdk/launcher/api/resource?channel_id=1&key=eYd89JmJ&launcher_id=18&sub_channel_id=1"
}

if (Test-Path "downloadjob.txt")
{
Write-Host Found uncompleted download! Continuing download...

if (Test-Path "audio_downloadjob.txt"){
.\aria2c.exe --input-file=$jobFileAudio --max-connection-per-server=16 --max-concurrent-downloads=8 --max-tries=0 --split=8 --continue --save-session session_audio.txt
$directory = Get-Location
$audioFileName =(Get-ChildItem -path $directory -Filter "Audio_*.zip").Name

# Extract audio package 
Write-Host "Extracting audio package..."
Expand-Archive -path $audioFileName.FullName

Remove-Item audio_downloadjob.txt -ErrorAction Continue
Remove-Item $audioFileName -ErrorAction Continue
}
Write-Host "Downloading main game files..."
.\aria2c --input-file="downloadjob.txt" --max-connection-per-server=16 --max-concurrent-downloads=8 --max-tries=0 --split=8 --continue --save-session session.txt

# Cleanups
Remove-Item aria2c.exe -ErrorAction Continue
Remove-Item downloadjob.txt -ErrorAction Continue

Write-Host Installed Genshin Impact version $latestVersion!
exit
}
# Display a menu to select a Game Region
Write-Host "Select a Game Region:"
$index = 1
$optionKeys = @($regions.Keys | Sort-Object)
$optionKeys | ForEach-Object {
    Write-Host "$index. $_"
    $index++
}

# Prompt the user for their selection
$selection = Read-Host "Enter the number for the game you want to install"
Write-Host

# Check if the selection is valid
if ($selection -ge 1 -and $selection -le $regions.Count)
{
    $selectedUrl = $regions[$optionKeys[$selection - 1]]

    try
    {
        $jsonString = Invoke-RestMethod -Uri $selectedUrl -Method Get
        $latestVersion = $jsonString.data.game.latest.version
        $decompressedPath = $jsonString.data.game.latest.decompressed_path
        $objectAudio = $jsonString.data.game.latest.voice_packs

        # Select Audio package
        Write-Host Select a language you want to install:
        $indexAudio = 1
        $objectAudio | ForEach-Object {
            "[$indexAudio] : $($_.language)"
            $indexAudio++
        }
        $selectedAudio = Read-Host -Prompt "Enter a number of the audio package you want to install"
        if ($selectedAudio -lt 1 -or $selectedAudio -gt $objectAudio.Count){
            Write-Error "Invalid selection!"
            exit
        }
        
        $selectedAudioItem = $objectAudio[$selectedAudio - 1]
        # Write-Host Audio Language : $selectedAudioItem.language
        # Write-Host Link : $selectedAudioItem.path

        # Generate config.ini file
        $configFileName = "config.ini"
        $configFilePath = Join-Path -Path $PWD -ChildPath $configFileName
        $configIniContent = @"
[General]
channel=1
game_version=$latestVersion
"@
        $configIniContent | Out-File -FilePath $configFilePath -Encoding utf8
        Write-Host Generated config.ini file!
        
        # Get pkg_version
        $pkgUri = $decompressedPath + "/" + "pkg_version"
        Write-Host Getting pkg_version file...
        # Write-Host $pkgUri
        Invoke-WebRequest -Uri $pkgUri -OutFile pkg_version
        $pkg_version = Get-Content -Path "pkg_version"
        
        # Grab aria2c from repo
        Write-Host "Getting aria2c from the repo..."
        $aria2cUri = "https://github.com/bagusnl/Genshin-MinimalInstaller/raw/main/tools/aria2c.exe"
        Invoke-WebRequest -Uri $aria2cUri -OutFile aria2c.exe

        # Parse and generate aria2c input file
        $jobFile = "downloadjob.txt"

        if (Test-Path $jobFile) { Remove-Item $jobFile -ErrorAction Continue }

        Write-Host "Generating aria2c input file..."
        
        # Use StringBuilder to make the job file faster
        $contentBuilder = [System.Text.StringBuilder]::new()

        foreach ($line in $pkg_version | ConvertFrom-Json) {
            $fullUri = "{0}/{1}" -f $decompressedPath, $line.remoteName
            $outFile = $line.remoteName
            $md5Hash = $line.md5

            # Append content to the StringBuilder
            [void]$contentBuilder.AppendLine("$fullUri")
            [void]$contentBuilder.AppendLine("    out=$outFile")
            [void]$contentBuilder.AppendLine("    checksum=md5=$md5Hash")
            [void]$contentBuilder.AppendLine("")
        }

        # Write all main download job
        $contentBuilder.ToString() | Out-File -FilePath $jobFile
        
        # Add audio package to the download list
        $jobFileAudio = "audio_downloadjob.txt"
        if (Test-Path $jobFileAudio) { Remove-Item $jobFileAudio -ErrorAction Continue }
        $fileOutAudio = New-Item -Path $jobFileAudio

        Write-Host Adding $selectedAudioItem.language audio package to the download job...
        $audioUri = $selectedAudioItem.path
        $audioHash = $selectedAudioItem.md5
        Add-Content -Path $fileOutAudio.FullName -value "$audioUri"
        Add-Content -Path $fileOutAudio.FullName -value "    checksum=md5=$audioHash"
        Add-Content -Path $fileOutAudio.FullName -value ""
        
        # Download audio archive then extract
        Write-Host "Downloading audio file..."
        .\aria2c.exe --input-file=$jobFileAudio --max-connection-per-server=16 --max-concurrent-downloads=8 --max-tries=0 --split=8 --continue --save-session session_audio.txt
        $audioFileUri = New-Object System.Uri($audioUri)
        $audioFileName = $uri.Segments[-1]
        Expand-Archive -path $audioFileName
        Remove-Item $audioFileName -ErrorAction Continue
        Remove-Item $jobFileAudio -ErrorAction Continue

        # Download main game files
        Write-Host "Downloading main game files..."
        .\aria2c --input-file=$jobFile --max-connection-per-server=16 --max-concurrent-downloads=8 --max-tries=0 --split=8 --continue --save-session session_main.txt

        # Cleanups
        Remove-Item downloadjob.txt -ErrorAction Continue
        Remove-Item aria2c.exe -ErrorAction Continue

        Write-Host Installed Genshin Impact version $latestVersion!
    }
    catch
    {
        Write-Host An error has occured!
        Write-Host $_
    }
}
else { 
    Write-Host Selection invalid!
    Write-Host Please re-run the script
}

# TODO
# - Code cleanup
# - Initialize statics on the top of the script
 #>