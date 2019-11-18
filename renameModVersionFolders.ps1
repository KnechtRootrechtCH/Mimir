$oldVersion = "1.6.1.3"
$newVersion = "1.6.1.4"
Get-ChildItem -Recurse | Where-Object {  $_.Name -eq $oldVersion -and $_.PSIsContainer} | ForEach-Object { Rename-Item $_.FullName $newVersion }
