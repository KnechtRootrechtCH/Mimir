function New-Archive {
    param (
        [Parameter(Mandatory=$true)]
        [string]$source,
        [Parameter(Mandatory=$true)]
        [string]$target,
        [int]$compressionLevel = 0
    )

    if(-not (Test-Path $source)){
        Write-Error "New-Archive :: Source path '$source' not found"
        return
    }

    if(Test-Path $target){
        Write-Debug "New-Archive :: Deleting existing file '$target'"
        Remove-Item $target
    }

    $files = "$source/*"
    Write-Debug "New-Archive :: Creating archive '$target' (compression: $compressionLevel)"
    7z a -tzip $target -mx0 $files | Out-Null

    Write-Debug "New-Archive :: Archive '$target' created"
    return $target
}

function Remove-ModDirectory {
    param (
        [Parameter(Mandatory=$true)]
        [string] $path
    )

    if(Test-Path $path){
        Write-Debug "Remove-ModDirecory :: $path "
        Remove-Item -Recurse -Force $path
    }
}

function Initialize-ModDirectory {
    param (
        [Parameter(Mandatory=$true)]
        [string] $path,
        [bool] $clearFolder = $true
    )

    if($clearFolder){
        Remove-ModDirectory $path
    }

    if(-not (Test-Path $path)){
        Write-Debug "Initialize-ModDirecory :: $path "
        New-Item $path -type Directory -force | out-null
    }
}

function Copy-ModContent {
    param (
        [Parameter(Mandatory=$true)]
        [string] $sourcePath,
        [Parameter(Mandatory=$true)]
        [string] $targetPath
    )
    $sourceItem = Get-Item $sourcePath
    
    if($sourceItem.PSIsContainer) {
        $targetItem = Get-Item $targetPath
        Write-Debug "Copy-ModContent :: $($sourceItem.FullName) => $($targetItem.FullName))"
        Copy-Item "$($sourceItem.FullName)\*" "$($targetItem.FullName)\" -Container -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Debug "Copy-ModContent :: $sourcePath => $targetPath/$($sourceItem.Name)"
        Copy-Item $sourceItem.FullName "$targetPath/$($sourceItem.Name)" -Recurse -Force -ErrorAction SilentlyContinue
    }
}