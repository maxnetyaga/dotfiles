[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

$env:Path = 'C:\msys64\ucrt64\bin;C:\msys64\usr\bin;' + $env:Path

Set-PSReadLineOption -EditMode Emacs

Import-Module -Name Microsoft.WinGet.CommandNotFound
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

function lf {
    $rg = Start-Process rg -ArgumentList '--files', '--color=never', '--encoding', 'UTF-8' -NoNewWindow -RedirectStandardOutput 'pipe' -PassThru
    $selected = $rg.StandardOutput | fzf
    # if ($selected) {
    #     try { Stop-Process -Id $rg.Id -ErrorAction SilentlyContinue } catch {}
    #     explorer $selected
    # } else {
    #     try { Stop-Process -Id $rg.Id -ErrorAction SilentlyContinue } catch {}
    # }
}