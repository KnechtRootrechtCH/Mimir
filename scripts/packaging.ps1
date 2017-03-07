function New-ModPackage {
    param (
        [Parameter(Mandatory=$true)]
        [string] $sourcePath,
        [Parameter(Mandatory=$true)]
        [string] $targetPath
    )

    $valid = Get-IsValidPackageSource $sourcePath
    if(-not $valid){
        Write-Error "New-ModPackage :: '$sourcePath' is a valid package source"
        return
    }

    $source = Get-Item $sourcePath
    $gameVersion = Get-ConfigValue "gameVersion"
    
    $versionFolder = "$($source.FullName)/$gameVersion"
    $stagingDirectory = Get-ConfigValue "stagingPath"
    $stagingPath = "$stagingDirectory/$($source.Name)"
    $resPath = "$stagingPath/res"
    Write-Debug "New-ModPackage :: Initializing staging directory"
    Initialize-ModDirectory $stagingPath

    Write-Debug "New-ModPackage :: Copying data to staging directory"
    Copy-ModContent $versionFolder $resPath

    $fileName = "$($source.Name).wotmod"
    Write-Debug "New-ModPackage :: Creating mod archive '$fileName'"
    $archive =  New-Archive $stagingPath "$targetPath/$fileName"

    Write-Debug "New-ModPackage :: Removing staging directory '$stagingPath'"
    Remove-ModDirectory $stagingPath
    return $archive
}

function Convert-ModToPackage {
    param (
        [Parameter(Mandatory=$true)]
        [string] $modPath,
        [bool] $archiveModDirectory = $false
    )

    $stagingPath = Get-ConfigValue "stagingPath"
    Initialize-ModDirectory $stagingPath $false
    $archivePath = Get-ConfigValue "archivePath"
    Initialize-ModDirectory $archivePath $false

    Write-Debug "Convert-ModToPackage :: $modPath"
    $directory = Get-Item $modPath
    $destination = $($directory.Parent.FullName)
    $mod = New-ModPackage $modPath $destination
    
    $destination = "$archivePath/$($directory.Name)"

    if($archiveModDirectory){
        Write-Debug "Convert-ModToPackage :: Archiving mod source directory"
        Move-Item -Path $directory -Destination $destination -force
    }
    return $mod
}

function Convert-ModToPackages {
    param (
        [Parameter(Mandatory=$true)]
        [string] $path,
        [bool] $archiveModDirectories = $false
    )

    Write-Info "Converting mods to packages ($path)"

    $directories = Get-ChildItem $path -Dir -Recurse
    $gameVersion = Get-ConfigValue "gameVersion"

    foreach($directory in $directories){
        if(-not (Test-Path $directory.FullName)){
            continue
        }
        $items = Get-ChildItem $directory.FullName -dir
        
        if($items.Count -lt 1){
            continue
        } elseif($items.Count -gt 1){
            continue
        } elseif($items[0].Name -ne $gameVersion){
            continue
        }

        Write-Step $directory.Name
        $mod = Convert-ModToPackage $directory.FullName $archiveModDirectories
    }
}

function Get-IsValidPackageSource {
    param(
        [Parameter(Mandatory=$true)]
        [string] $sourcePath
    )

        if(-not (Test-Path $sourcePath)){
        Write-Error "New-ModPackage :: Source path '$sourcePath' not found"
        return
    }

    $source = Get-Item $sourcePath
    $items = Get-ChildItem $source -dir

    $gameVersion = Get-ConfigValue "gameVersion"
    if($items.Count -lt 1){
        Write-Debug "Get-IsValidPackageSource :: '$sourcePath' is not a valid wotmod package source path: no sub directories"
        return $false
    } elseif($items.Count -gt 1){
        Write-Debug "Get-IsValidPackageSource :: '$sourcePath' is not a valid wotmod package source path: multiple sub directories"
        return $false
    } elseif($items[0].Name -ne $gameVersion){
        Write-Debug "Get-IsValidPackageSource :: '$sourcePath' is not a valid wotmod package source path: sub directory does not match $gameVersion"
        return $false
    }
    Write-Debug "Get-IsValidPackageSource :: '$sourcePath' is a valid package source path"
    return $true
}