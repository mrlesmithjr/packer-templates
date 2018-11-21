# Notify for download and notify for install
$WindowsUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
$AutoUpdatePath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

If (Test-Path -Path $WindowsUpdatePath) {
    Remove-Item -Path $WindowsUpdatePath -Recurse
}
New-Item $WindowsUpdatePath -Force
New-Item $AutoUpdatePath -Force
Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 0
Set-ItemProperty -Path $AutoUpdatePath -Name AUOptions -Value 2
Set-ItemProperty -Path $AutoUpdatePath -Name ScheduledInstallDay -Value 0
Set-ItemProperty -Path $AutoUpdatePath -Name ScheduledInstallTime -Value 3