$ansible_script = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
$chocolatey_script = "https://chocolatey.org/install.ps1"

# Setup WinRM for Ansible Management
Set-ExecutionPolicy Bypass -Scope Process -Force; iex (
    (New-Object System.Net.WebClient).DownloadString($ansible_script))

# Install Chocolatey Package Manager
Set-ExecutionPolicy Bypass -Scope Process -Force; iex (
    (New-Object System.Net.WebClient).DownloadString($chocolatey_script))

# Enable Remote Desktop
(Get-WmiObject Win32_TerminalServiceSetting -Namespace root\cimv2\TerminalServices).SetAllowTsConnections(1, 1)
(Get-WmiObject -Class "Win32_TSGeneralSetting" -Namespace root\cimv2\TerminalServices -Filter "TerminalName='RDP-tcp'").SetUserAuthenticationRequired(0)

# Install Chocolatey Packages
choco install -y 7zip