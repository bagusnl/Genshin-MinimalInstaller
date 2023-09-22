Write-Host Minimal installer for Genshin Impact
$regions = @{
    "Genshin-GLB" = "https://sdk-os-static.mihoyo.com/hk4e_global/mdk/launcher/api/resource?channel_id=1&key=gcStgarh&launcher_id=10&sub_channel_id=0"
    "Genshin-CN" = "https://sdk-static.mihoyo.com/hk4e_cn/mdk/launcher/api/resource?channel_id=1&key=eYd89JmJ&launcher_id=18&sub_channel_id=1"
}

if (Test-Path "downloadjob.txt")
{
Write-Host Found uncompleted download! Continuing download...
.\aria2c --input-file="downloadjob.txt" --max-connection-per-server=16 --max-concurrent-downloads=8 --max-tries=0 --split=8 --continue --save-session session.txt
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
        
        # Parse and generate aria2c input file
        $jobFile = "downloadjob.txt"
        if (Test-Path $jobFile)
        {
            Remove-Item $jobFile -ErrorAction SilentlyContinue
        }
        
        $fileOut = New-Item -Path $jobFile
        Write-Host Generating aria2c input file...
        foreach($line in $pkg_version)
        {
            $item = ConvertFrom-Json -InputObject $line
            # Write-Host Found $item.remoteName! Adding to $fileOut...
            $fullUri = "{0}/{1}" -f $decompressedPath, $item.remoteName
            $outFile = $item.remoteName
            $md5Hash = $item.md5
            Add-Content -Path $fileOut.FullName -value "$fullUri"
            Add-Content -Path $fileOut.FullName -value "    out=$outFile"
            Add-Content -Path $fileOut.FullName -value "    checksum=md5=$md5Hash"
            Add-Content -Path $fileOut.FullName -value ""
        }
        
        # Add audio package to the download list
        $audioUri = $selectedAudioItem.path
        $audioHash = $selectedAudioItem.md5
        Write-Host Adding $selectedAudioItem.language audio package to the download job...
        Add-Content -Path $fileOut.FullName -value "$audioUri"
        Add-Content -Path $fileOut.FullName -value "    out=/"
        Add-Content -Path $fileOut.FullName -value "    checksum=md5=$audioHash"
        Add-Content -Path $fileOut.FullName -value ""
        
        # Grab aria2c from repo
        $aria2cUri = "https://github.com/bagusnl/Genshin-MinimalInstaller/raw/main/tools/aria2c.exe"
        Invoke-WebRequest -Uri $aria2cUri -OutFile aria2c.exe
        
        # Download files using aria2c
        $jobFileName = $fileOut.FullName
        .\aria2c --input-file=$jobFileName --max-connection-per-server=16 --max-concurrent-downloads=8 --max-tries=0 --split=8 --continue --save-session session.txt
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

# Extract audio package file
$audioFileUri = New-Object System.Uri($audioUri)
$audioFileName = $uri.Segments[-1]
Expand-Archive -path $audioFileName.FullName

# Cleanups
Remove-Item aria2c.exe -ErrorAction SilentlyContinue
Remove-Item downloadjob.txt -ErrorAction SilentlyContinue
Remove-Item $audioFileName

Write-Host Installed Genshin Impact version $latestVersion!