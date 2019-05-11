configuration wspull {
    Import-DscResource -ModuleName PSDesiredStateConfiguration -ModuleVersion 1.1

    WindowsFeatureSet wspull {
        Name = 'Microsoft-Windows-Subsystem-Linux'
        Ensure = 'Present'
    }

    LocalConfigurationManager {
        RebootNodeIfNeeded = $true
        ConfigurationMode = 'ApplyOnly'
        ActionAfterReboot = 'ContinueConfiguration'
        RefreshMode = 'Push'
    }
}