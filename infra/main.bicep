targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string = 'dev'

@minLength(1)
@description('Primary location for all resources')
param location string
param resourceGroupName string
param managedIdentityName string
param virtualNetworkName string
param sqlServerName string
param sqlDbName string
param keyVaultName string
param containerImageName string
param serverFarmName string
param serverSiteName string

var abbrs = loadJsonContent('./abbreviations.json')

// tags that should be applied to all resources.
var tags = {
  // Tag all resources with the environment name.
  'azd-env-name': environmentName
}

#disable-next-line no-unused-vars
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
#disable-next-line no-unused-vars

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourceGroupName}-${location}'
  location: location
  tags: tags
}

module managedIdentity 'managedidentity.bicep' = {
  name: 'managedIdentity'
  scope: rg
  params: {
    name: managedIdentityName
  }
}

module virtualnetwork 'virtualnetwork.bicep' = {
  name: 'virtualnetwork'
  scope: rg
  params: {
    virtualnetworkname: virtualNetworkName
  }
}

module keyvault 'keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    keyvaultname: keyVaultName
    managedIdentityName: managedIdentityName
    privatednszonename: 'privatelink.vaultcore.azure.net'
    privateendpointname: 'KVEndpointConnection'
    privateendpointnameconnectionname: 'KVEndpoint'
    virtualnetworkname: virtualNetworkName
  }
  dependsOn: [
    managedIdentity
  ]
}

module sqldatabase 'sqldatabase.bicep' = {
  name: 'sqldatabase'
  scope: rg
  params: {
    sqlservername: sqlServerName
    sqldbname: sqlDbName
    sqlendpointname: 'sqlendpoint'
    keyvaultname: keyVaultName
    privatelinkdnszonesname: 'privatelink.database.windows.net'
    virtualnetworkname: virtualNetworkName
    managedidentityname: managedIdentityName
  }
  dependsOn: [
    keyvault
    managedIdentity
  ]
}

module containerinstance 'containerinstance.bicep' = {
  name: 'containerinstance'
  scope: rg
  params: {
    sitename: serverSiteName
    serverfarmname: serverFarmName
    virtualnetworkname: virtualNetworkName
    dockerimagename: containerImageName
    managedIdentityName: managedIdentityName
    keyvaultname: keyVaultName
  }
  dependsOn: [
    managedIdentity
    sqldatabase
  ]
}
