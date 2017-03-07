$configFilePath = ".\config.xml"
$global:logLevel = 5


function Initialize-Configuration {
    if(Test-Path $configFilePath) {
        Try {
            #Load config file
            $configFile = Get-Item $configFilePath
            $config = [xml](get-content $configFile)

            #Load app settings
            $global:wotAppSettings = @{}

            foreach ($node in $config.configuration.appsettings.add) {
                $value = $node.Value
                $global:wotAppSettings[$node.Key] = $value
            }
        }
        Catch [system.exception]{
            Write-Error "Initialize-Configuration :: Error while reading configuration file '$configFile'!"
            exit
        }
    } else {
        Write-Error "Initialize-Configuration :: Config file '$configFile' not found!"
        exit
    }
}

function Get-LogLevel {
    Get-ConfigValue "logLevel"
}

function Get-ConfigValue {
    param(
        $key
    )
    return $global:wotAppSettings[$key]
}

function Get-PresetsList {
    param(
        $key
    )
    return $global:wotAppSettings[$key]
}

function Save-ConfigValue {
    param(
        $key,
        $value
    )
    $global:wotAppSettings[$key] = $value

    $configFile = gi $configFilePath
    $config = [xml](get-content $configFile)
    foreach ($node in $config.configuration.appsettings.add) {
        if($node.key -eq $key) {
            $node.value = $value
        }
    }
    $config.Save($configFile.Fullname)
}

Initialize-Configuration