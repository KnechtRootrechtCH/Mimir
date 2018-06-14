$oldVersion = "1.0.2.0"
$newVersion = "1.0.2.1"
Get-ChildItem -Recurse | Where-Object {  $_.Name -eq $oldVersion -and $_.PSIsContainer} | ForEach-Object { Rename-Item $_.FullName $newVersion }
