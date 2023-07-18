using 'main.bicep' /*TODO: Provide a path to a bicep template*/

param environmentName = '\${AZURE_ENV_NAME}'
param location = '\${AZURE_LOCATION}'
param resourceGroupName = 'blackistechconferencedemo'
param managedIdentityName = 'blackistechid'
param virtualNetworkName = 'virtualnetwork'
param sqlServerName = 'blackistechdemosql'
param sqlDbName = 'blackistechdb'
param keyVaultName = 'blackIsTechKv'
param containerImageName = 'chall88/blackistech:latest'
param serverFarmName = 'blackistechfarm'
param serverSiteName = 'blackistechdemosite'
