[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$env:Path = 'C:\msys64\ucrt64\bin;C:\msys64\usr\bin;' + $env:Path

Set-PSReadLineOption -EditMode Emacs

Import-Module -Name Microsoft.WinGet.CommandNotFound
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

function lf {
    $selected = fzf --bind "start:reload:rg --files --color=never --encoding UTF-8" --disabled
    if ($selected) {
        explorer $selected
    }
}