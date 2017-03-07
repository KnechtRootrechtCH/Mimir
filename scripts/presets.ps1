function Get-ModPresets {
    param (
        [bool] $recurse = $false
    )
    $presetPath = Get-ConfigValue "presetPath"
    
    if($recurse) {
        $presets = Get-ChildItem -path $presetPath -Recurse -Include "*.xml"
    } else {
        $presets = Get-ChildItem -path "$presetPath/*.xml"
    }
    
    return $presets | ForEach-Object { $_.BaseName }
}

function Get-ModPreset {
    param (
        [Parameter(Mandatory=$true)]
        [string] $name
    )

    $presetPath = Get-ConfigValue "presetPath"
    $presets = Get-ChildItem -path $presetPath -Recurse -Include "$name.xml"
    if(-not $presets -or $presets.Count -eq 0) {
        Write-Error "Get-ModPreset :: Unable to locate preset '$name'"
        return
    } elseif ($presets.Count -gt 1) {
        Write-Error "Get-ModPreset :: Multiple presets with name '$name' found"
        return
    }

    # Load config file
    $configFile = Get-Item $presets[0].FullName
    $config = [xml]( Get-Content $configFile )
    return $config.preset
}

function Install-ModPreset {
    param (
        [Parameter(Mandatory=$true)]
        [string] $name,
        [string] $basePath,
        [bool] $createWotmodPackages = $true
    )

    if(-not $basePath) {
        $basePath = Get-ConfigValue "gamePath"
    }

    $presetConfig = Get-ModPreset $name
    if(-not $presetConfig) {
        Write-Error "Install-ModPreset :: Unable to load preset config for  '$name'"
        return
    }

    Write-Debug "Install-ModPreset : $($presetConfig.Description)"
    Write-Debug "Install-ModPreset :: targetPath: $basePath"
    Write-Step "Preparing target folders"
    Clear-ModFolders $basePath

    foreach($mod in $presetConfig.mod){
        Write-Step "Installing $mod"
        $sourcePath = Get-ModSourcePath $mod
        $type = Get-ModType $sourcePath
        $targetPath = Get-ModsTargetPath $type $basePath
        Install-Mod $mod $sourcePath $type $targetPath $createWotmodPackages
    }
}

function New-ModPresetBuild {
    param (
        [Parameter(Mandatory=$true)]
        [string] $name
    )

    $stagingDirectory = Get-ConfigValue "stagingPath"
    $stagingPath = "$stagingDirectory/$name"

    $buildPath = Get-ConfigValue "buildTargetPath"
    $targetPath = "$buildPath/$name.zip"

    Install-ModPreset $name $stagingPath
    Write-Step "Creating zip archive"
    $archive = New-Archive $stagingPath $targetPath 5

    Write-Step "Cleaning staging folder"
    Remove-ModDirectory $stagingPath
}