# Undo-ForegroundLockTimeout.ps1
# Restores ForegroundLockTimeout to 0

$keyPath = "HKCU:\Control Panel\Desktop"
$valueName = "ForegroundLockTimeout"
$originalValue = 0x0

# Ensure the key exists
if (-not (Test-Path $keyPath)) {
    Write-Error "Registry path not found: $keyPath"
    exit 1
}

try {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $originalValue -Type DWord
    Write-Host "✅ ForegroundLockTimeout reset to 0 (instant window focus allowed)"
} catch {
    Write-Error "❌ Failed to reset value: $_"
    exit 1
}
