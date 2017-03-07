. "$PSScriptRoot\utils.ps1"
. "$PSScriptRoot\configuration.ps1"
. "$PSScriptRoot\fileOperations.ps1"
. "$PSScriptRoot\installation.ps1"
. "$PSScriptRoot\packaging.ps1"
. "$PSScriptRoot\presets.ps1"

function Start-ModQuickInstall {
    param (
        [string] $debug
    )

    if($debug) {
        Write-Color -Cyan "MIMIR Mod Install (debug)"
        $mods = Get-ConfigValue "quickInstallModsDebug"
    } else {
        Write-Color -Cyan "MIMIR Mod Install"
        $mods = Get-ConfigValue "quickInstall"
    }
    
    foreach($mod in $mods.Split(";")){
        Write-Step "$mod"
        Install-Mod $mod
    }
    Write-Color -Cyan "Done"
}

function Start-PresetQuickInstall {
    $preset = Get-ConfigValue "quickInstsallPreset"
    Write-Color -Cyan "MIMIR Preset Install: $preset"
    Install-ModPreset $preset
    # clear staging directory
    Write-Step "Cleanup"
    Remove-ModDirectory (Get-ConfigValue "stagingPath")
    Write-Color -Cyan "Done"
}

function Start-PresetBuild {
    Write-Color -Cyan "MIMIR Build Presets"
    $presets = Get-ModPresets -recurse:$false
    foreach($preset in $presets) {
        Write-Info
        Write-Info "Building Preset : $preset"
        New-ModPresetBuild $preset
        Write-Step "Preset build complete"
        Write-Info
    }

    # clear staging directory
    Write-Step "Cleanup"
    Remove-ModDirectory (Get-ConfigValue "stagingPath")
    Write-Color -Cyan "Done"
}

function Start-ClearModFolders {
    Write-Color -Cyan "MIMIR Clear Mod Folders"
    Clear-ModFolders
    Write-Color -Cyan "Done"
}

function Start-ConvertModPackages {
    $path = Get-ConfigValue "convertSourcePath"
    Write-Color -Cyan "MIMIR Package Convert (Path: $path)"
    $archiveModDirectories = (Get-ConfigValue "archiveConverteddMods") -eq "true"
    Convert-ModToPackages $path $archiveModDirectories
    # clear staging directory
    Write-Step "Cleanup"
    Remove-ModDirectory (Get-ConfigValue "stagingPath")
    Write-Color -Cyan "Done"
}