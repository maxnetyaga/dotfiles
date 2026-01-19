$env:Path = 'C:\msys64\ucrt64\bin;C:\msys64\usr\bin;' + $env:Path

Import-Module -Name Microsoft.WinGet.CommandNotFound
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

function fl {
    $selected = Get-ChildItem -Recurse -File | ForEach-Object FullName | fzf
    if ($selected) {
        explorer /select,"$selected"
    }
}