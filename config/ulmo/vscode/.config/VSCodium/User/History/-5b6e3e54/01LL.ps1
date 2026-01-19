[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$env:Path = 'C:\msys64\ucrt64\bin;C:\msys64\usr\bin;' + $env:Path

Import-Module -Name Microsoft.WinGet.CommandNotFound
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

function lf {
    $list = rg --files --color=never --encoding UTF-8
    if (-not $list) { return }

    $selected = $list | Out-String -Stream | fzf
    if ($selected) {
        echo "explorer "$selected""
    }
}