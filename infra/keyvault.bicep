param keyvaultname string
param privateendpointname string
param privatednszonename string
param virtualnetworkname string
param managedIdentityName string
param privateendpointnameconnectionname string
param serviceconnectionobjectId string
param location string = resourceGroup().location
resource keyvaultname_resource 'Microsoft.KeyVault/vaults@2022-11-01' = {
  name: keyvaultname
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: serviceconnectionobjectId
        permissions: {
          keys: []
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }
      },{
        tenantId: subscription().tenantId
        objectId: reference(resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', managedIdentityName), '2018-11-30', 'Full').properties.principalId
        permissions: {
          keys: []
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }
      }
    ]
    enabledForDeployment: true
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: false
    vaultUri: 'https://${keyvaultname}.vault.azure.net/'
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}

resource privatednszonename_resource 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privatednszonename
  location: 'global'
  properties: {
    maxNumberOfRecordSets: 25000
    maxNumberOfVirtualNetworkLinks: 1000
    maxNumberOfVirtualNetworkLinksWithRegistration: 100
    numberOfRecordSets: 2
    numberOfVirtualNetworkLinks: 1
    numberOfVirtualNetworkLinksWithRegistration: 0
    provisioningState: 'Succeeded'
  }
}

resource keyvaultname_privateendpointnameconnectionname 'Microsoft.KeyVault/vaults/privateEndpointConnections@2022-11-01' = {
  parent: keyvaultname_resource
  name: privateendpointnameconnectionname
  location: resourceGroup().location
  properties: {
    provisioningState: 'Succeeded'
    privateEndpoint: {}
    privateLinkServiceConnectionState: {
      status: 'Approved'
      actionsRequired: 'None'
    }
  }
  dependsOn: [
    privateendpointname_resource
  ]
}

resource privatednszonename_keyvaultname 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: privatednszonename_resource
  name: '${keyvaultname}'
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: '10.0.1.4'
      }
    ]
  }
}

resource Microsoft_Network_privateDnsZones_SOA_privatednszonename 'Microsoft.Network/privateDnsZones/SOA@2018-09-01' = {
  parent: privatednszonename_resource
  name: '@'
  properties: {
    ttl: 3600
    soaRecord: {
      email: 'azureprivatedns-host.microsoft.com'
      expireTime: 2419200
      host: 'azureprivatedns.net'
      minimumTtl: 10
      refreshTime: 3600
      retryTime: 300
      serialNumber: 1
    }
  }
}

resource privatednszonename_we7g5e376t5mi 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privatednszonename_resource
  name: 'we7g5e376t5mi'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', virtualnetworkname)
    }
  }
}

resource privateendpointname_resource 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: privateendpointname
  location: resourceGroup().location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateendpointnameconnectionname
        id: '${resourceId('Microsoft.Network/privateEndpoints', privateendpointname)}/privateLinkServiceConnections/${privateendpointnameconnectionname}'
        properties: {
          privateLinkServiceId: keyvaultname_resource.id
          groupIds: [
            'vault'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    subnet: {
      id: '${resourceId('Microsoft.Network/virtualNetworks', virtualnetworkname)}/subnets/Subnet-2'
    }
    ipConfigurations: []
    customDnsConfigs: [
      {
        fqdn: '${keyvaultname}.vault.azure.net'
        ipAddresses: [
          '10.0.1.4'
        ]
      }
    ]
  }
}

output keyvaultname string = keyvaultname_resource.name
