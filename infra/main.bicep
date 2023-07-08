targetScope = 'subscription'

// The main bicep module to provision Azure resources.
// For a more complete walkthrough to understand how this file works with azd,
// see https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string = 'blackistechconference'

@minLength(1)
@description('Primary location for all resources')
param location string = 'eastus'

// Optional parameters to override the default azd resource naming conventions.
// Add the following to main.parameters.json to provide values:
// "resourceGroupName": {
//      "value": "myGroupName"
// }
param resourceGroupName string = 'blackistechconferencedemo'

var abbrs = loadJsonContent('./abbreviations.json')

// tags that should be applied to all resources.
var tags = {
  // Tag all resources with the environment name.
  'azd-env-name': environmentName
}

// Generate a unique token to be used in naming resources.
// Remove linter suppression after using.
#disable-next-line no-unused-vars
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Name of the service defined in azure.yaml
// A tag named azd-service-name with this value should be applied to the service host resource, such as:
//   Microsoft.Web/sites for appservice, function
// Example usage:
//   tags: union(tags, { 'azd-service-name': apiServiceName })
#disable-next-line no-unused-vars

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

module managedIdentity 'managedidentity.bicep' = {
  name: 'managedIdentity'
  scope: rg
  params: {
    name: 'blackistechid'
  }
}

module virtualnetwork 'virtualnetwork.bicep' = {
  name: 'virtualnetwork'
  scope: rg
  params: {
    virtualnetworkname: 'virtualnetwork'
  }
}

module keyvault 'keyvault.bicep' = {
  name: 'keyvault'
  scope: rg
  params: {
    keyvaultname: 'blackistechkv'
    managedIdentityName: 'blackistechid'
    privatednszonename: 'privatelink.vaultcore.azure.net'
    privateendpointname: 'KVEndpointConnection'
    privateendpointnameconnectionname: 'KVEndpoint'
    virtualnetworkname: 'virtualnetwork'
  }
}

module sqldatabase 'sqldatabase.bicep' = {
  name: 'sqldatabase'
  scope: rg
  params: {
    sqlservername: 'blackistechdemosql'
    sqldbname: 'blackistechdb'
    sqlendpointname: 'sqlendpoint'
    keyvaultname: 'blackistechkv'
    privatelinkdnszonesname: 'privatelink.database.windows.net'
    virtualnetworkname: 'virtualnetwork'
    managedidentityname: 'blackistechid'
  }
  dependsOn: [
    keyvault
  ]
}

module containerinstance 'containerinstance.bicep' = {
  name: 'containerinstance'
  scope: rg
  params: {
    sitename: 'blackistechdemosite'
    serverfarmname: 'blackistechfarm'
    virtualnetworkname: 'virtualnetwork'
    dockerimagename: 'chall88/demofrontend:latest'
    managedIdentityName: 'blackistechid'
    keyvaultname: 'blackistechkv'
  }
}
