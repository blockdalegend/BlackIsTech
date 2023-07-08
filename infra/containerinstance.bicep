param sitename string
param serverfarmname string
param virtualnetworkname string
param dockerimagename string
param managedIdentityName string
param keyvaultname string

resource serverfarmname_resource 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: serverfarmname
  location: resourceGroup().location
  sku: {
    name: 'B1'
    tier: 'Basic'
    size: 'B1'
    family: 'B'
    capacity: 1
  }
  kind: 'linux'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    freeOfferExpirationTime: '2023-04-18T16:28:17.3733333'
    reserved: true
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

resource sitename_resource 'Microsoft.Web/sites@2022-03-01' = {
  name: sitename
  location: resourceGroup().location
  kind: 'app,linux,container'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', managedIdentityName)}': {}
    }
  }
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sitename}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sitename}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarmname_resource.id
    reserved: true
    isXenon: false
    hyperV: false
    vnetRouteAllEnabled: true
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOCKER|${dockerimagename}'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 0
      minimumElasticInstanceCount: 0
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Development'
        }
        {
          name: 'AZURE_CLIENT_ID'
          value: reference(resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', managedIdentityName), '2018-11-30', 'Full').properties.clientId
        }
        {
          name: 'MSI_ENDPOINT'
          value: 'http://169.254.169.254/'
        }
        {
          name: 'KEY_VAULT_NAME'
          value: keyvaultname
        }
      ]
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    customDomainVerificationId: '5093B07C5183F72A24F2A3AAC9C7A3CEAEE278D66D94A3A1F0D73D4F9FE7C416'
    containerSize: 0
    dailyMemoryTimeQuota: 0
    httpsOnly: true
    redundancyMode: 'None'
    publicNetworkAccess: 'Enabled'
    storageAccountRequired: false
    virtualNetworkSubnetId: '${resourceId('Microsoft.Network/virtualNetworks', virtualnetworkname)}/subnets/Subnet-1'
    keyVaultReferenceIdentity: resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', managedIdentityName)
  }
}

resource sitename_ftp 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: sitename_resource
  name: 'ftp'
  location: resourceGroup().location
  properties: {
    allow: true
  }
}

resource sitename_scm 'Microsoft.Web/sites/basicPublishingCredentialsPolicies@2022-03-01' = {
  parent: sitename_resource
  name: 'scm'
  location: resourceGroup().location
  properties: {
    allow: true
  }
}

resource sitename_sitename_azurewebsites_net 'Microsoft.Web/sites/hostNameBindings@2022-03-01' = {
  parent: sitename_resource
  name: '${sitename}.azurewebsites.net'
  location: resourceGroup().location
  properties: {
    siteName: sitename
    hostNameType: 'Verified'
  }
}

resource sitename_ae848459_eb29_4eae_aba7_a8090bbd3677_Subnet_1 'Microsoft.Web/sites/virtualNetworkConnections@2022-03-01' = {
  parent: sitename_resource
  name: 'ae848459-eb29-4eae-aba7-a8090bbd3677_Subnet-1'
  location: resourceGroup().location
  properties: {
    vnetResourceId: '${resourceId('Microsoft.Networks/ViritualNetworks', virtualnetworkname)}/subnets/Subnet-1'
    isSwift: true
  }
}