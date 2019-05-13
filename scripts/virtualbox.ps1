if ($env:PACKER_BUILDER_TYPE -eq "virtualbox-iso") {
  Write-Host "Installing Guest Additions"
  if (Test-Path d:\VBoxWindowsAdditions.exe) {
    Start-Process -FilePath "d:\cert\VBoxCertUtil.exe" -ArgumentList "add-trusted-publisher d:\cert\vbox-sha1.cer" -Wait -NoNewWindow
    Start-Process -FilePath "d:\cert\VBoxCertUtil.exe" -ArgumentList "add-trusted-publisher d:\cert\vbox-sha256.cer" -Wait -NoNewWindow
    Write-Host "Mounting Drive with VBoxWindowsAdditions"
    Start-Process -FilePath "d:\VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait
  }
  if (Test-Path e:\VBoxWindowsAdditions.exe) {
    Start-Process -FilePath "e:\cert\VBoxCertUtil.exe" -ArgumentList "add-trusted-publisher e:\cert\vbox-sha1.cer" -Wait -NoNewWindow
    Start-Process -FilePath "e:\cert\VBoxCertUtil.exe" -ArgumentList "add-trusted-publisher e:\cert\vbox-sha256.cer" -Wait -NoNewWindow
    Write-Host "Mounting Drive with VBoxWindowsAdditions"
    Start-Process -FilePath "e:\VBoxWindowsAdditions.exe" -ArgumentList "/S" -Wait
  }
}