# investigate how the pull server is setup :)
tree C:\pullserver /F /A

# database?
New-DSCPullServerAdminConnection -SQLServer . -Database DSC -Credential sa
Get-DSCPullServerAdminRegistration
Get-DSCPullServerAdminStatusReport

# pull server feature
dism /Online /Get-FeatureInfo /FeatureName:dsc-service

# black magic?

# show other windows, Get-Pullaris  and return to slides after