$parameters = @{ }
$parameters['location'] = "westeurope"
$parameters['storageAccountName'] = "pmsawesteu"
$parameters['logAnalyticsName'] = "pmlogwesteu"
$parameters['managedIdentityName'] = "pm-identity-westeu"
$parameters['acrName'] = "pmacrwesteu"
$parameters['acaEnvName'] = "pm-aca-env-westeu"
$parameters['acaName'] = "pm-aca-prom-westeu"

$resourceGroup = 'PlatformmonitorDev'

New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroup `
    -TemplateFile (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath '/infrastructure/main.bicep') `
    -TemplateParameterObject $parameters `
    -Verbose