# stage configuration
# download required module
Install-Module -Name ComputerManagementDsc -Scope CurrentUser -Force

# configuration
configuration baseConfig {
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc

    Node baseConfig {
        TimeZone WestEUTime {
            IsSingleInstance = 'Yes'
            TimeZone = 'W. Europe Standard Time'
        }
    }
}

# compile
baseConfig -OutputPath C:\pullserver\configurations

# create checksum?
# New-DscChecksum -Path C:\pullserver\configurations\baseConfig.mof -Force

# add module to pull server module store
# stage module
tree /A C:\Users\$env:USERNAME\Documents\PowerShell\Modules\ComputerManagementDsc

# modules distributed by pull server must be zipped but have special requirement
$version = (Get-Module ComputerManagementDsc -ListAvailable).Version.ToString()
Compress-Archive -Path C:\Users\$env:USERNAME\Documents\PowerShell\Modules\ComputerManagementDsc\$version\* -DestinationPath C:\pullserver\modules\ComputerManagementDsc_$version.zip -Force

# create checksum?
# New-DscChecksum -Path C:\pullserver\Modules\ComputerManagementDsc_$version.zip  -Force

# onboard node to pull server and have it converge
Set-Item WSMan:\localhost\Client\TrustedHosts -Value * -Force
$lcm = New-PSSession -ComputerName wslcm

$lcm | Enter-PSSession

[dsclocalconfigurationmanager()]
configuration lcm {
    Settings {
        RefreshMode = 'Pull'
    }

    ConfigurationRepositoryWeb PullWeb {
        ServerURL               = 'http://wspull:8080/api'
        RegistrationKey         = [guid]::Empty
        AllowUnsecureConnection = $true
        ConfigurationNames = 'baseConfig'
    }

    ReportServerWeb PullWeb {
        ServerURL               = 'http://wspull:8080/api'
        RegistrationKey         = [guid]::Empty
        AllowUnsecureConnection = $true
    }
}
lcm
Set-DscLocalConfigurationManager .\lcm -Verbose

Update-DscConfiguration -Wait -Verbose

Exit-PSSession