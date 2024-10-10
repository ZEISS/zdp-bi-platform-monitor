$parameters = @{ }
$parameters['location'] = "westeurope"
$parameters['storageAccountName'] = "pmsawesteu"
$parameters['logAnalyticsName'] = "pmlogwesteu"
$parameters['managedIdentityName'] = "pm-identity-westeu"
$parameters['acrName'] = "pmacrwesteu"
$parameters['keyVaultName'] = "pm-keyvault-westeu"
$parameters['acaEnvName'] = "pm-aca-env-westeu"
$parameters['acaNamePrometheus'] = "pm-aca-prometheus-westeu"
$parameters['acaNameExporter'] = "pm-aca-exporter-westeu"
$parameters['acaNameAlertManager'] = "pm-aca-alertmanager-westeu"
$parameters['acaNameAlertsReceiver'] = "pm-aca-alertsreceiver-westeu"
$parameters['grafanaName'] = "pm-grafana-westeu"

$resourceGroup = 'PlatformmonitorDev'

New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroup `
    -TemplateFile (Join-Path -Path (Split-Path $PSScriptRoot -Parent) -ChildPath '/infrastructure/main.bicep') `
    -TemplateParameterObject $parameters `
    -Verbose