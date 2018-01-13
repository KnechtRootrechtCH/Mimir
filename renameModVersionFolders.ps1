$oldVersion = "0.9.21.0.2"
$newVersion = "0.9.21.0.3"
Get-ChildItem -Recurse | Where-Object {  $_.Name -eq $oldVersion -and $_.PSIsContainer} | ForEach-Object { Rename-Item $_.FullName $newVersion }