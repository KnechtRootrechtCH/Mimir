function Write-Command {
    param (
        [string] $message = "Done.",
        [switch] $verbose = $false
    )
    if ($verbose -eq $true) {
        write-host "> $message" -f DarkCyan
    }
}

function Write-Done {
    param (
        [string] $message = "Done."
    )
    Write-Host $message -f Green
}

function Write-Option {
    param(
        [string] $key,
        [string] $description
    )

    Write-Host "[ " -n; Write-Host $key -f Cyan -n; Write-Host " ] " $description
}

function Write-Color {
    # DO NOT SPECIFY param(...)
    #    we parse colors ourselves.
    Write-ColorTokens $args | Out-Null
}

function Write-ColorTokens {
    param(
        $tokens
    )
    $args

    $allColors = @("-Black","-DarkBlue","-DarkGreen","-DarkCyan","-DarkRed","-DarkMagenta","-DarkYellow","-Gray", "-DarkGray","-Blue","-Green","-Cyan","-Red","-Magenta","-Yellow","-White")
    $aliases = @{ "-Success" = "Green"; "-Highlight" = "Magenta"; "-Error" = "Red"; "-Warning" = "Yellow"; "-Info" = "Gray"; "-Normal" = "Gray"; "-Quiet" = "DarkGray"; }

    $foreground = (Get-Host).UI.RawUI.ForegroundColor
    $background = (Get-Host).UI.RawUI.BackgroundColor

    [bool]$nonewline = $false
    $color = $aliases["-Normal"]
    $sofar = "" + (" " * $log_indent)

    foreach($t in $tokens) {
        if ($t -eq "-nonewline") {
            $nonewline = $true

        } elseif ($t -eq "-foreground" -or $t -eq "-normal") {
            if ($sofar) {
                Write-Host $sofar -foreground $color -nonewline
            }
            $color = $foreground
            $sofar = ""

        } elseif ($allColors -contains $t -or $aliases.Keys -contains $t) {
            if ($sofar) {
                Write-Host $sofar -foreground $color -nonewline
            }

            if ($aliases.Keys -contains $t) {
                $color = $aliases[$t]
            } else {
                $color = $t.substring(1)
            }

            if ($color -eq "Normal") {
                $color = $foreground
            }
            $sofar = ""

        } else {
            $sofar += "$t "
        }
    }

    # last bit done special
    if (!$nonewline) {
        Write-Host $sofar -foreground $color
    } elseif ($sofar) {
        Write-Host $sofar -foreground $color -nonewline
    }
}

function Write-Step {
    $a = New-Object System.Collections.ArrayList
    @("-Cyan", "*", "-Gray") |% { $a.Add($_) | Out-Null }
    $args |% {
        if ($_ -eq "-Normal") {
            $_ = "-Gray"
        }
        $a.Add($_) | Out-Null
    }

    if ($host.ui.rawui.CursorPosition.X -ne 0) { Write-Host "" }

    $log_indent++
    Write-ColorTokens $a | Out-Null
    $log_indent--
}

function Write-Prompt {
    Write-Color -Cyan "\> " -nonewline
}

function Write-Debug {
    if (Get-LogLevel -le 0) {
        $a = New-Object System.Collections.ArrayList
        @("-Quiet", "DEBUG: ") |% { $a.Add($_) | Out-Null }
        $args |% {
            if ($_ -eq "-Normal") {
                $_ = "-Quiet"
            }
            $a.Add($_) | Out-Null
        }

        if ($host.ui.rawui.CursorPosition.X -ne 0) { Write-Host "" }
        Write-ColorTokens $a
    }
}

function Write-Info {
    if (Get-LogLevel -le 1) {
        $a = New-Object System.Collections.ArrayList
        @("-Info") |% { $a.Add($_) | Out-Null }
        $args |% {
            if ($_ -eq "-Normal") {
                $_ = "-Info"
            }
            $a.Add($_) | Out-Null
        }

        if ($host.ui.rawui.CursorPosition.X -ne 0) { Write-Host "" }
        Write-ColorTokens $a | Out-Null
    }
}

function Write-Warning {
    if (Get-LogLevel -le 2) {
        $a = New-Object System.Collections.ArrayList
        @("-Warning", "  WARN:") |% { $a.Add($_) | Out-Null }
        $args |% {
            if ($_ -eq "-Normal") {
                $_ = "-Warning"
            }
            $a.Add($_) | Out-Null
        }

        if ($host.ui.rawui.CursorPosition.X -ne 0) { Write-Host "" }
        Write-ColorTokens $a | Out-Null
    }
}

function Write-Error {
    if (Get-LogLevel -le 3) {
        $a = New-Object System.Collections.ArrayList
        @("-Error", "  ERROR:") |% { $a.Add($_) | Out-Null }
        $args |% {
            if ($_ -eq "-Normal") {
                $_ = "-Error"
            }
            $a.Add($_) | Out-Null
        }

        if ($host.ui.rawui.CursorPosition.X -ne 0) { Write-Host "" }
        Write-ColorTokens $a | Out-Null
    }
}

function Write-Success {
    $a = New-Object System.Collections.ArrayList
    @("-Success") |% { $a.Add($_) | Out-Null }
    $args |% {
        if ($_ -eq "-Normal") {
            $_ = "-Success"
        }
        $a.Add($_) | Out-Null
    }

    Write-ColorTokens $a | Out-Null
}

function Write-Terminate {
    Write-Color -Gray "."
    exit
}

function Write-InvalidInput {
    Write-Color -Red "Invalid input!"
    Write-Terminate
}

function Import-Assembly($assemblyName, $report) {
     if (([appdomain]::currentdomain.getassemblies() | Where {$_ -match $assemblyName}) -eq $null) {
          if ($report -ne $false) {
              Write-Output "Loading $assemblyName assembly."
          }
          [Void] [System.Reflection.Assembly]::LoadWithPartialName($assemblyName)
          } else {
          if ($report -ne $false) {
              Write-Output "$assemblyName is already loaded."
          }
     }
}

function ToArray {
    begin {
        $output = @();
    }
    process {
        $output += $_;
    }
    end {
        return ,$output;
    }
}

function IsNumeric {
    param(
        [Parameter(Mandatory=$true)]
        [int] $x
    )
    try {
        0 + $x | Out-Null
        return $true
    } catch {
        return $false
    }
}