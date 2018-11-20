# We first need to disable password complexity settings in order to add the vagrant user
$seccfg = [IO.Path]::GetTempFileName()
secedit /export /cfg $seccfg
(Get-Content $seccfg) | Foreach-Object {$_ -replace "PasswordComplexity\s*=\s*1", "PasswordComplexity=0"} | Set-Content $seccfg
secedit /configure /db $env:windir\security\new.sdb /cfg $seccfg /areas SECURITYPOLICY
del $seccfg
Write-Host "Complex Passwords have been disabled." -ForegroundColor Green

# Create Vagrant user
$userDirectory = [ADSI]"WinNT://localhost"
$user = $userDirectory.Create("User", "vagrant")
$user.SetPassword("vagrant")
$user.SetInfo()
$user.UserFlags = 64 + 65536 # ADS_UF_PASSWD_CANT_CHANGE + ADS_UF_DONT_EXPIRE_PASSWD
$user.SetInfo()
$user.FullName = "vagrant"
$user.SetInfo()
&net "localgroup" "administrators" "/add" "vagrant"
Write-Host "User: 'vagrant' has been created as a local administrator." -ForegroundColor Green

# We finally enable password complexity settings after adding the Vagrant user
$seccfg = [IO.Path]::GetTempFileName()
secedit /export /cfg $seccfg
(Get-Content $seccfg) | Foreach-Object {$_ -replace "PasswordComplexity\s*=\s*0", "PasswordComplexity=1"} | Set-Content $seccfg
secedit /configure /db $env:windir\security\new.sdb /cfg $seccfg /areas SECURITYPOLICY
del $seccfg
Write-Host "Complex Passwords have been enabled." -ForegroundColor Green