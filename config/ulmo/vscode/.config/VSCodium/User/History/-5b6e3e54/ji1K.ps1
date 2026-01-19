[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$env:Path = 'C:\msys64\ucrt64\bin;C:\msys64\usr\bin;' + $env:Path

Set-PSReadLineOption -EditMode Emacs

Import-Module -Name Microsoft.WinGet.CommandNotFound
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

function lf {
    $selected = rg --files --color=never --encoding UTF-8 | Out-String -Stream | fzf
    if ($selected) {
        explorer "$selected"
    }
}