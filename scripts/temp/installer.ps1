function Install-Mod {
    param (
        $sourcePath,
        $targetPath,
        $name = $sourcePath
    )

    Write-Host "Installing '$name'"

    $sourcePathValid = Test-Path $sourcePath
    if(-not $sourcePathValid){
        Write-Color -Red "source path '$sourcePath' is invalid!"
        return
    }

    $targetPathValid = Test-Path $targetPath
    $targetPathValid += $targetPath.EndsWith("res_mods/")
    if(-not $targetPathValid){
        Write-Color -Red "target path '$targetPath' is invalid!"
        return
    }



    Write-Step "Copying files to game folder"
    Write-Debug "'$sourcePath' > '$targetPath'"
    Copy-Item "$sourcePath/*" $targetPath -Recurse -Force -ErrorAction SilentlyContinue
    Write-Color -Cyan "Done"
}

function Uninstall-Mods {
    param(
        $targetPath
    )

    Write-Host "Wiping all mods"

    $targetPathValid = Test-Path $targetPath
    $targetPathValid += $targetPath.EndsWith("res_mods/")
    if(-not $targetPathValid){
        Write-Color -Red "target path '$targetPath' is invalid!"
        return
    }

    Write-Step "Deleting mod folder"
    Write-Debug $targetPath

    Remove-Item -Recurse -Force $targetPath -ErrorAction Continue

    $version = Get-ConfigValue "gameVersion"
    $versionFolderPath = "$targetPath$version"
    Write-Step "Creating empty mod folder"
    Write-Debug $versionFolderPath
    $resModsFolder = New-Item -ItemType Directory -Path $versionFolderPath -Force -ErrorAction Continue

    Write-Color -Cyan "Done"
}

function Create-ZipFile
{
    param (
        $fileName,
        $sourcePath
    )
    Write-Host "Creating zip file '$fileName'"

    $valid = Test-Path $fileName
    if($valid){
        Write-Step "Delete existing zip file"
        Remove-Item $fileName
    }

    Write-Step "Adding files to archive."
    Write-Debug "'$sourcePath' > '$fileName'"

   Add-Type -Assembly System.IO.Compression.FileSystem
   $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
   [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcePath, $fileName, $compressionLevel, $true)

   Write-Color -Cyan "Done"
}