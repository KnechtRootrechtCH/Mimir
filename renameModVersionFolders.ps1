$oldVersion = "0.9.21.0.3"
$newVersion = "0.9.22.0"
Get-ChildItem -Recurse | Where-Object {  $_.Name -eq $oldVersion -and $_.PSIsContainer} | ForEach-Object { Rename-Item $_.FullName $newVersion }
