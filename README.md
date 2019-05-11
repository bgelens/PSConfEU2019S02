# PSConfEU2019S02

Pullaris - A Custom DSC Pull Server written in PowerShell and running on Polaris

The session is planned on June 6th at 1:00PM in the red room.

[Download the slide deck.](https://raw.githubusercontent.com/bgelens/PSConfEU2019S02/master/Pullaris.pptx)

## Demo Environment

The entire demo environment can be deployed using the link below (it requires you to have an Azure subscription).

[![Deploy to Azure](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fbgelens%2FPSConfEU2019S02%2Fmaster%2Fdeploy.json)

### Post Deployment / Start Session steps

On wspull (`psconfeu-0<revisionNumber>-pull.westeurope.cloudapp.azure.com`):

* Run `SetupWSL.ps1` (ubuntu is setup under the user context)
* Open VS Code and install PowerShell extension (leave at ISE color as bright theme is requested by PSConf).
* Switch to PSv6 for Integrated terminal
* Reload VS Code and use workspace folder: `C:\Users\Public\Desktop\PSConfEU2019S02-master\`.
