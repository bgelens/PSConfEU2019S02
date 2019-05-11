<#
    setup pullaris on pwsh on wsl (ubuntu)
#>

Remove-Module PSReadLine

$sqlCred = [pscredential]::new('sa', (ConvertTo-SecureString 'Welkom01' -AsPlainText -Force))
New-DSCPullServerAdminSQLDatabase -SQLServer . -Credential $sqlCred -Name DSC -Confirm:$false

$sqlConn = New-DSCPullServerAdminConnection -SQLServer . -Database DSC -Credential $sqlCred -DontStore

Start-Pullaris -Port 8080 -DatabaseConnection $sqlConn -ConfigurationDirectory /mnt/c/pullserver/configurations -ModuleDirectory /mnt/c/pullserver/modules -AuthorizationKey ([guid]::Empty)
