<# 
    Now let's hookup DSCPullServerAdmin for DB interaction to see an example of registration being handled.

    how to figure out what the protocol is?
    Read DSCDPM
    IlSpy (peek into Pull Server DLL)
    Fiddler to capture http requests and responses
    Look at Traek
    A lot of trial and error (observe LCM behavior)
#>

New-DSCPullServerAdminConnection -SQLServer . -Credential sa -Database DSC

# currently registered nodes
Get-DSCPullServerAdminRegistration

# create registration route
# note that Polaris can only use variables defined in global scope due to usage of Register-ObjectEvent (makes it hard to ship app as module)
New-PolarisPutRoute -Path "/api/Nodes\(AgentId=':ID'\)" -Scriptblock {
    $script:Polaris.Log(($Request.Body | ConvertTo-Json -Depth 100))
    if ($Request.Headers['ProtocolVersion'] -ne '2.0') {
        $Response.StatusCode = 400
        $Response.Send('Client protocol version is invalid.')
    } else {
        $agentId = $Request.Parameters.ID
        $existingNode = Get-DSCPullServerAdminRegistration -AgentId $agentId
        if ($null -eq $existingNode) {
            $newArgs = @{
                AgentId = $agentId
                LCMVersion = $Request.Body.AgentInformation.LCMVersion
                NodeName = $Request.Body.AgentInformation.NodeName
                IPAddress = $Request.Body.AgentInformation.IPAddress -split ';' -split ',' | Where-Object -FilterScript {$_ -ne [string]::Empty}
                ConfigurationNames = $Request.Body.ConfigurationNames
                Confirm = $false
            }
            New-DSCPullServerAdminRegistration @newArgs
        } else {
            $updateArgs = @{
                LCMVersion = $Request.Body.AgentInformation.LCMVersion
                NodeName = $Request.Body.AgentInformation.NodeName
                IPAddress = $Request.Body.AgentInformation.IPAddress -split ';' -split ',' | Where-Object -FilterScript {$_ -ne [string]::Empty}
                ConfigurationNames = $Request.Body.ConfigurationNames
                Confirm = $false
            }
            $existingNode | Set-DSCPullServerAdminRegistration @updateArgs
        }
        $Response.StatusCode = 204
        $Response.Headers.Add('ProtocolVersion', '2.0')
    }
}
$polaris = Get-Polaris
$polaris.Logger = {
    param($LogItem)
    Write-Host $LogItem
}
Start-Polaris -Port 8081 -UseJsonBodyParserMiddleware

Start-Process powershell
<# onboard node (use psv5)
[dsclocalconfigurationmanager()]
configuration lcm {
    Settings {
        RefreshMode = 'Pull'
    }

    ConfigurationRepositoryWeb PullWeb {
        ServerURL               = 'http://wspull:8081/api'
        RegistrationKey         = [guid]::Empty
        AllowUnsecureConnection = $true
    }
}
lcm
Set-DscLocalConfigurationManager .\lcm -Verbose
#>

# see the node is onboarded
Get-DSCPullServerAdminRegistration

Stop-Polaris; Clear-Polaris