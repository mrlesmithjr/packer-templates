if ($env:PACKER_BUILDER_TYPE -eq "vmware-iso") {
  $vmware_tools_iso = "c:\Windows\Temp\windows.iso"
  Write-Output "Mounting VMware Tools ISO - $vmware_tools_iso"
  Mount-DiskImage -ImagePath $vmware_tools_iso
  $vmware_tools_exe = (
    (Get-DiskImage -ImagePath $vmware_tools_iso | Get-Volume).Driveletter + ':\setup.exe')
  $vmware_tools_install_params = '/S /v "/qr REBOOT=R"'
  Start-Process $vmware_tools_exe $vmware_tools_install_params -Wait
}