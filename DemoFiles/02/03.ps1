# how does pullaris work? First look at Polaris
Get-Module -Name Polaris -ListAvailable

# polaris basics
Get-Command -Module Polaris

# create a new Get Route and start Polaris
New-PolarisRoute -Path /helloworld -Method GET -Scriptblock {
    $script:Polaris.Log(($Request | ConvertTo-Json))
    if ($Request.Query['name']) {
        $Response.Send('Hello ' + $Request.Query['name'])
    } elseif ($Request.Body.name) {
        $Response.Send('Hello ' + $Request.Body.name)
    } else {
        $Response.Send('Hello World')
    }
}
$polaris = Get-Polaris
$polaris.Logger = {
    param($LogItem)
    Write-Host $LogItem
}
Start-Polaris -UseJsonBodyParserMiddleware -Port 8081

# call the polaris function in another terminal (blocking)
start pwsh
irm http://localhost:8081/helloworld -Method Post
irm http://localhost:8081/helloworld?name=PSConfEU
irm http://localhost:8081/helloworld -Body (@{name='PSConfEU2019!'} | ConvertTo-Json) -ContentType 'application/json'

# you can use regex in the routes to capture parameters.
New-PolarisPutRoute -Path "/api/Nodes\(AgentId=':ID'\)" -Scriptblock {
    $script:Polaris.Log("Got call from agentid: $($Request.Parameters.ID)")
}

# call from different terminal
irm "http://localhost:8081/api/Nodes(AgentId='733e17c6-8f69-4131-b49a-157f6088e15e')" -Method Put

Stop-Polaris; Clear-Polaris
