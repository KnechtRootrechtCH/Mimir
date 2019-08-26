$oldVersion = "1.6.0.2"
$newVersion = "1.6.0.3"
Get-ChildItem -Recurse | Where-Object {  $_.Name -eq $oldVersion -and $_.PSIsContainer} | ForEach-Object { Rename-Item $_.FullName $newVersion }
