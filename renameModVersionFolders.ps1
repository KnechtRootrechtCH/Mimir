$oldVersion = "1.4.1.1"
$newVersion = "1.4.1.2"
Get-ChildItem -Recurse | Where-Object {  $_.Name -eq $oldVersion -and $_.PSIsContainer} | ForEach-Object { Rename-Item $_.FullName $newVersion }
