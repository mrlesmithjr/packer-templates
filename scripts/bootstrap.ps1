# This script is called from the answerfile

# Add The Oracle Cert For VirtualBox
certutil -addstore -f "TrustedPublisher" a:\oracle-cert.cer

# Supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

# Set network to private
$ifaceinfo = Get-NetConnectionProfile
Set-NetConnectionProfile -InterfaceIndex $ifaceinfo.InterfaceIndex -NetworkCategory Private

Function Enable-WinRM {
    Write-Host "Enable WinRM"
    netsh advfirewall firewall set rule group="remote administration" new enable=yes
    netsh advfirewall firewall add rule name="Open Port 5985" dir=in action=allow protocol=TCP localport=5985

    winrm quickconfig -q
    winrm quickconfig -transport:http
    winrm set winrm/config '@{MaxTimeoutms="7200000"}'
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="0"}'
    winrm set winrm/config/winrs '@{MaxProcessesPerShell="0"}'
    winrm set winrm/config/winrs '@{MaxShellsPerUser="0"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/client/auth '@{Basic="true"}'

    net stop winrm
    sc.exe config winrm start= auto
    net start winrm

}

Enable-WinRM
