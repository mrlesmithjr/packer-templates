if ($env:PACKER_BUILDER_TYPE -eq "virtualbox-iso") {
    Write-Host "Installing Guest Additions"
    if (Test-Path d:\VBoxWindowsAdditions.exe) {
        Write-Host "Mounting Drive with VBoxWindowsAdditions"
        Start-Process -FilePath "d:\VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait
    }
    if (Test-Path e:\VBoxWindowsAdditions.exe) {
        Write-Host "Mounting Drive with VBoxWindowsAdditions"
        Start-Process -FilePath "e:\VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait
    }
}