param (
    [switch] $CopyDemoOnly
)

# disable servermanager
$null = Get-ScheduledTask -TaskName servermanager | Disable-ScheduledTask

# download demo files
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/bgelens/PSConfEU2019S02/archive/master.zip' -OutFile $env:TEMP\master.zip
Expand-Archive -Path $env:TEMP\master.zip -DestinationPath c:\Users\Public\Desktop -Force

# disable firewall
Get-NetFirewallProfile | Set-NetFirewallProfile -Enabled False

if ($CopyDemoOnly) {
    return
}

# download pullaris
Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/bgelens/Pullaris/archive/master.zip' -OutFile $env:TEMP\pullarismaster.zip
Expand-Archive -Path $env:TEMP\pullarismaster.zip -DestinationPath c:\ -Force

$ProgressPreference = 'SilentlyContinue'

# download sql 2017 express setup file
$sqlExpressUri = 'https://download.microsoft.com/download/5/E/9/5E9B18CC-8FD5-467E-B5BF-BADE39C51F73/SQLServer2017-SSEI-Expr.exe'
Invoke-WebRequest -Uri $sqlExpressUri -UseBasicParsing -OutFile "$env:TEMP\SQLServer2017-SSEI-Expr.exe"

# write configuration ini
@'
[OPTIONS]
ROLE="AllFeatures_WithDefaults"
ENU="True"
FEATURES=SQLENGINE
INSTANCENAME="MSSQLSERVER"
INSTANCEID="MSSQLSERVER"
SECURITYMODE="SQL"
ADDCURRENTUSERASSQLADMIN="True"
TCPENABLED="1"
SAPWD="Welkom01"
'@ | Out-File -FilePath c:\Configuration.ini -Force

# download setupfiles
Start-Process -FilePath "$env:TEMP\SQLServer2017-SSEI-Expr.exe" -ArgumentList @(
    '/Action=Download',
    '/Quiet',
    '/MEDIAPATH=c:\Windows\TEMP'
) -Wait

# extract setupfiles
Start-Process -FilePath "C:\Windows\Temp\sqlexpr_x64_enu.exe" -ArgumentList @(
    '/x:c:\setup /q'
) -Wait
 
# install sql 2017 (this will take some time!)
Start-Process -FilePath "c:\setup\setup.exe" -ArgumentList @(
    '/ACTION="Install"'
    '/ConfigurationFile=C:\Configuration.ini',
    '/IAcceptSqlServerLicenseTerms',
    '/QUIET'
) -Wait

# place ubuntu on disk (setup is handled by user using SetupWSL.ps1)
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile Ubuntu.zip -UseBasicParsing
Expand-Archive ./Ubuntu.zip C:/Ubuntu
$machineenv = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
[System.Environment]::SetEnvironmentVariable("PATH", $machineenv + ";C:\Ubuntu", "Machine")
New-Item -Path C:\Ubuntu -Name ubuntu.exe -ItemType SymbolicLink -Value C:\Ubuntu\ubuntu1804.exe

# install pwsh on windows using msi install
Invoke-WebRequest -UseBasicParsing -Uri https://github.com/PowerShell/PowerShell/releases/download/v6.2.0/PowerShell-6.2.0-win-x64.msi -OutFile $env:TEMP\PowerShell-6.2.0-win-x64.msi
Start-Process -Wait -ArgumentList "/package $env:TEMP\PowerShell-6.2.0-win-x64.msi /quiet ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1 ENABLE_PSREMOTING=1 REGISTER_MANIFEST=1" -FilePath msiexec.exe

# install dscpullserveradmin and polaris on pwsh
& 'C:\Program Files\PowerShell\6\pwsh.exe' -NoProfile -Command Install-module DSCPullServerAdmin, Polaris -Scope AllUsers -Force

# install pullaris on pwsh
Copy-Item -Path C:\Pullaris-master\Pullaris -Recurse -Destination 'C:\Program Files\PowerShell\Modules'

# install vs code
Invoke-WebRequest -UseBasicParsing -Uri https://go.microsoft.com/fwlink/?Linkid=852157 -OutFile $env:TEMP\vscodesetup.exe
Start-Process -Wait -ArgumentList '/VERYSILENT /MERGETASKS=!runcode' -FilePath $env:TEMP\vscodesetup.exe

# add shortcuts to desktop
New-Item -Path c:\Users\Public\Desktop -Name pwsh.lnk -ItemType SymbolicLink -Value 'C:\Program Files\PowerShell\6\pwsh.exe'
New-Item -Path c:\Users\Public\Desktop -Name vscode.lnk -ItemType SymbolicLink -Value 'C:\Program Files\Microsoft VS Code\Code.exe'
New-Item -Path c:\Users\Public\Desktop -Name ubuntu.lnk -ItemType SymbolicLink -Value 'C:\Ubuntu\ubuntu.exe'

# setup pull server directory structure
$null = New-Item -ItemType Directory -Path c:\ -Name pullserver -Force
$null = New-Item -ItemType Directory -Path c:\pullserver -Name modules -Force
$null = New-Item -ItemType Directory -Path c:\pullserver -Name configurations -Force

# restart
shutdown /r /t 30
