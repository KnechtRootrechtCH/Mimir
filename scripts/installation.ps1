function Clear-ModFolders {
    param (
        [string] $basePath
    )
    if(-not $basePath) {
        $basePath =  Get-ConfigValue "gamePath"
    }

    $gameVersion = Get-ConfigValue "gameVersion"
    $mods = Get-ModsTargetPath "mods" $basePath
    $resMods = Get-ModsTargetPath "res_mods" $basePath

    Initialize-ModDirectory $mods $true
    Initialize-ModDirectory $resMods $true
    Initialize-ModDirectory "$resMods/$gameVersion"
}

function Get-ModsTargetPath {
    param (
        [Parameter(Mandatory=$true)]
        [string] $type,
        [string] $basePath
    )

    if(-not $basePath) {
        $basePath =  Get-ConfigValue "gamePath"
    }
    $gameVersion = Get-ConfigValue "gameVersion"

    $path = ""

    switch($type) {
        "res_mods" {
            $path = Get-ConfigValue "resModsFolderPatern"
            break
        }
        "files" {
            $path = Get-ConfigValue "resModsFolderPatern"
            break
        }
        "mods" {
            $path = Get-ConfigValue "modsFolderPatern"
            break
        }
        "wotmod" {
            $path = Get-ConfigValue "modsFolderPatern"
            break
        }
        default {
            Write-Error "Get-PathForModType :: Unknown mod type '$type'"
            return
        }
    }

    $path = $path.Replace("{gameVersion}", $gameVersion).Replace("{basePath}", $basePath)
    Write-Debug "Get-ModsTargetPath :: type: $type; basePath: $basePath -> $path"
    return $path
}

function Get-ModType {
    param (
        [Parameter(Mandatory=$true)]
        [string] $modSourcePath
    )
    $mod = Get-Item $modSourcePath
    if(-not $mod){
        Write-Error "Get-ModType :: Unable to find mod at '$modSourcePath"
    }

    if($mod.PSIsContainer) {
        return "files"
    }

    if($mod.Extension -eq ".wotmod") {
        return "wotmod"
    }

    Write-Error "Get-ModType :: Unable to determine mod type for mod at '$modSourcePath"
    return
}

function Get-ModSourcePath {
    param (
        [Parameter(Mandatory=$true)]
        [string] $modName
    )

    $contentPath = Get-ConfigValue "contentPath"
    $mods = Get-ChildItem -path $contentPath -r | Where-Object { $_.Name -eq $modName -or $_.Name -eq "$modName.wotmod"}

    if(-not $mods -or ($mods.Count -eq 0)) {
        Write-Error "Get-ModSourcePath :: No mods found with name '$modName"
        return
    }
    if($mods.Count -gt 1) {
        Write-Error "Get-ModSourcePath :: Multiple mods found with name '$modName"
        return
    }

    $path = $mods.FullName
    return $path
}

function Install-Mod {
    param (
        [Parameter(Mandatory=$true)]
        [string] $name,
        [string] $sourcePath,
        [string] $type,
        [string] $targetBasePath,
        [bool] $createWotmodPackage = $false
    )
    if(-not $sourcePath) {
        $sourcePath = Get-ModSourcePath $name
    }
    if(-not $sourcePath) {
        Write-Error "Install-Mod :: Unable to determine source path for mod '$name'"
        return
    }

    if(-not $type) {
        $type = Get-ModType $sourcePath
    }
    if(-not $type) {
        Write-Error "Install-Mod :: Unable to determine type for mod '$name'"
        return
    }

    if($createWotmodPackage -and $type -eq "files") {
        $valid = Get-IsValidPackageSource $sourcePath
        if($valid){
            $stagingPath = Get-ConfigValue "stagingPath"
            $sourcePath = New-ModPackage $sourcePath $stagingPath
            $type = "wotmod"
        }
    }

    $targetPath = Get-ModsTargetPath $type $targetBasePath
    if(-not $targetPath) {
        Write-Error "Install-Mod :: Unable to determine target path for mod '$name'"
        return
    }

    if($type -eq "files"){
        Copy-ModContent "$sourcePath/*" $targetPath
    } else {
        Copy-ModContent $sourcePath $targetPath
    }
    
}