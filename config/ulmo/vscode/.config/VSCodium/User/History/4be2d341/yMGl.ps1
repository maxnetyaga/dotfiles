# Set-ForegroundLockTimeout.ps1
# Sets ForegroundLockTimeout to 0x30d40 (200000 ms)

$keyPath = "HKCU:\Control Panel\Desktop"
$valueName = "ForegroundLockTimeout"
$newValue = 0x30d40

# Ensure the key exists
if (-not (Test-Path $keyPath)) {
    Write-Error "Registry path not found: $keyPath"
    exit 1
}

try {
    Set-ItemProperty -Path $keyPath -Name $valueName -Value $newValue -Type DWord
    Write-Host "✅ ForegroundLockTimeout set to 0x30d40 (200000 ms)"
} catch {
    Write-Error "❌ Failed to set value: $_"
    exit 1
}
