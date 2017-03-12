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
        "mods" {
            $path = Get-ConfigValue "modsFolderPatern"
            break
        }
        "wotmod" {
            $path = Get-ConfigValue "wotmodFolderPatern"
            break
        }
        "mixed" {
            $path = "{basePath}"
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

    Write-Debug "Get-ModType :: Getting mod type for source path '$modSourcePath"

    if($mod.Extension -eq ".wotmod") {
        return "wotmod"
    }

    if($mod.PSIsContainer) {
        $dir = Get-ChildItem -path $mod.FullName -Directory | Where-Object { $_.Name -eq "res_mods_content" }
        if($dir.Count -eq 1){
            return "mixed"
        }

        $dir = Get-ChildItem -path $mod.FullName -Directory | Where-Object { $_.Name -eq "mods_content" }
        if($dir.Count -eq 1){
            return "mixed"
        }

        $packages = Get-ChildItem -path $mod.FullName -File | Where-Object { $_.Extension -eq ".wotmod" }
        if($packages.Count -gt 1){
            return "mixed"
        }

        return "res_mods"
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

    if($createWotmodPackage -and $type -eq "res_mods") {
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

    Write-Debug "Install-Mod :: '$name' -> type: $type"
    if($type -eq "res_mods" -or $type -eq "mods" -or $type -eq "wotmod") {
        Initialize-ModDirectory $targetPath $false
        Copy-ModContent $sourcePath $targetPath
        return
    }
    
    if ($type -eq "mixed") {
        Write-Debug "Install-Mod :: Mod '$name' is a mixed mod package"

        $dir = Get-ChildItem -path $sourcePath -Directory | Where-Object { $_.Name -eq "res_mods_content" }
        if($dir.Count -eq 1){
            Install-Mod $name $dir.FullName "res_mods" $targetBasePath
        }

        $dir = Get-ChildItem -path $sourcePath -Directory | Where-Object { $_.Name -eq "mods_content" }
        if($dir.Count -eq 1){
            Install-Mod $name $dir.FullName "mods" $targetBasePath
        }

        $packages = Get-ChildItem -path $sourcePath -File | Where-Object { $_.Extension -eq ".wotmod" }
        foreach($package in $packages) { 
            Install-Mod $name $package.FullName "wotmod" $targetBasePath
        }

        return
    }
    
    Write-Error "Install-Mod ::Mmod '$name' has an invalid mod type ($type)"
}