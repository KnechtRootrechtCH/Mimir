function Write-MainMenu {
    Write-Color -Cyan "MIMIR: World of Tanks Mod Installer"
    Write-Host

    $contentPath = Get-ConfigValue "contentPath"
    $options = @(
        @{ "Code" = 1; Description = "Build preset"; "Value" = "buildPreset" };
        @{ "Code" = 2; Description = "Install preset"; "Value" = "installPreset" };
        @{ "Code" = 3; Description = "Uninstall preset"; "Value" = "uninstallPreset" };
        @{ "Code" = 4; Description = "Manually install mods"; "Value" = $contentPath };
    )
    $option = Write-OptionsMenu $options

    if($option.value -eq "uninstallPreset"){
        $preset = Select-Preset
        if($preset){
            $gamePath = $preset.gamePath
            $targetPath = "$gamePath\res_mods\"
            Uninstall-Mods $targetPath
        }

    } elseif($option.value -eq "installPreset"){
        $preset = Select-Preset

        if($preset){
            Write-Preset $preset $false
        }

    } elseif($option.value -eq "buildPreset"){
        $preset = Select-Preset

        if($preset){
            Write-Preset $preset $true
        }

    } else {
        $targetPath = Get-ResModsPath
        Write-FolderMenu $option.value $targetPath

    }
    Write-MainMenu
}

function Select-Preset {
    $options = @(
        @{ "Code" = 0; Description = "[Back]"; "Value" = "back" }
    )
    $options += $global:presets

    $option = Write-OptionsMenu $options

    $value = $option.Value
    if($value -eq "back")
    {
        return
    }

    return $value
}

function Write-PresetsMenu {
    param (
        $compileBuild
    )
    $options = @(
        @{ "Code" = 0; Description = "[Back]"; "Value" = "back" }
    )
    $options += $global:presets
    $option = Write-OptionsMenu $options

    $value = $option.Value
    if($value -eq "back")
    {
        return
    }
    Write-Preset $value $compileBuild
}

function Write-Preset {
    param (
        $preset,
        $compileBuild,
        $terminateAfterInstallation = $true
    )

    Write-Host
    if($compileBuild) {
        Write-Color -Cyan "Building preset '$($preset.name)'"
        $directory = Get-Item ".\"
        $gamePath = "$($directory.FullName)\bin\$($preset.name)"
        $targetPath = "$gamePath\res_mods\"
    } else {
        Write-Color -Cyan "Installing preset '$($preset.name)'"
        $gamePath = $preset.gamePath
        $targetPath = "$gamePath\res_mods\"
    }

    $targetPathValid = Test-Path $targetPath
    if ($targetPathValid) {
        Write-Step "Target path: $targetPath"
    } elseif ($compileBuild) {
        Write-Step "Creating target path: $targetPath"
        New-Item -ItemType Directory -Force -Path $targetPath | out-null
    } else {
        Write-Color -Red "Target path '$targetPath' is invalid!"
        return
    }

    Uninstall-Mods $targetPath
    foreach($mod in $preset.mod){
        Install-Mod $mod.path $targetPath $mod.name
    }

    if($compileBuild){
        $directory = Get-Item ".\"
        Create-ZipFile "$($directory.FullName)\bin\$($preset.name).zip" $targetPath
    }

    Write-Host
    if($compileBuild){
        Write-Color -Cyan "Preset build completed"
    } else {
        Write-Color -Cyan "Preset installation completed"
    }
    Write-Host

    if($preset.interactive -eq "true"){
        $contentPath = Get-ConfigValue "contentPath"
        Write-FolderMenu $contentPath $targetPath
    } elseif ($terminateAfterInstallation ){
        Write-Terminate
    }
}

function Write-FolderMenu(){
    param(
        $folderPath,
        $targetPath
    )

    $options = Get-FolderOptions $folderPath
    Write-Host
    $option = Write-OptionsMenu $options

    if($option.Value -eq "back")
    {
        return
    }

    $value = $option.value
    if($value.Name.StartsWith("_")){
        Write-FolderMenu $value.FullName $targetPath
    } else {
        Install-Mod $value.FullName $targetPath $option.Description
    }

    Write-FolderMenu $folderPath $targetPath
}

function Get-FolderOptions(){
    param(
        $baseFolder
    )

    $i = 0
    $options = @(
       @{ "Code" = 0; Description = "[Back]"; "Value" = "back" };
    )

    $folders = Get-ChildItem -Path $baseFolder -Directory

    foreach($folder in $folders){
        $i++
        $name = $folder.BaseName
        if($name.StartsWith("_")){
            $TextInfo = (Get-Culture).TextInfo
            $name = $name.Replace("_", " ")
            $name = $name.Trim()
            $name = $TextInfo.ToTitleCase($name)
            $name = "[$name]"
        } else {
            $name = $name.Replace("_", " ")
        }
        $options += @{ "Code" = $i; Description = $name; "Value" = $folder };
    }

    return $options;
}

function Write-OptionsMenu(){
    param(
        $options,
        $message = "Please select an option:",
        $allowQuit = $true,
        $terminateOnError = $false,
        $addQuit = $allowQuit
    )

    if($addQuit){
        $options += @{ "Code" = "Q"; Description = "[Quit]"; "Value" = $null };
    }

    Write-Host
    Write-Host $message

    foreach($option in $options){
        Write-Option $option.Code $option.Description
    }

    Write-Prompt
    $userInput = Read-Host
    $userInput = $userInput.ToUpper()
    $userInput = $userInput.Trim()

    if($allowQuit){
        if($userInput -eq ""){
            Write-Terminate
        } elseif($userInput -eq "Q"){
            Write-Terminate
        }
    }

    $option = $options | Where { $_.Code -like $userInput }

    if($option){
        return $option
    } elseif ($terminateOnError){
        Write-Color -Red "Invalid input!"
        Write-Terminate
    } else {
        Write-Color -Red "Invalid input!"
        Write-Host
        Write-OptionsMenu $options $message $allowQuit $terminateOnError $false
    }
}