$env:Path = 'C:\masm32\bin;' + $env:Path
$env:Path = 'C:\masm32\include;' + $env:Path
$env:Path = 'C:\masm32\lib;' + $env:Path

Import-Module -Name Microsoft.WinGet.CommandNotFound
Invoke-Expression (&starship init powershell)
