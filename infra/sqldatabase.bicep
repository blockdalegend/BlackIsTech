param sqlservername string
param sqldbname string
param sqlendpointname string
param keyvaultname string
param privatelinkdnszonesname string
param virtualnetworkname string
param managedidentityname string

var adminpassword = '${uniqueString(guid(resourceGroup().id, deployment().name))}Tg2%'

resource privatelinkdnszonesname_resource 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: privatelinkdnszonesname
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

resource sqlservername_resource 'Microsoft.Sql/servers@2022-08-01-preview' = {
  name: sqlservername
  location: resourceGroup().location
  kind: 'v12.0'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', managedidentityname)}': {}
    }
  }
  properties: {
    administratorLogin: '${sqlservername}admin'
    administratorLoginPassword: adminpassword
    version: '12.0'
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
    primaryUserAssignedIdentityId: resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', managedidentityname)
    restrictOutboundNetworkAccess: 'Disabled'
  }
}

resource privatelinkdnszonesname_sqlservername_A 'Microsoft.Network/privateDnsZones/A@2018-09-01' = {
  parent: privatelinkdnszonesname_resource
  name: '${sqlservername}A'
  properties: {
    ttl: 10
    aRecords: [
      {
        ipv4Address: '10.0.2.4'
      }
    ]
  }
}

resource Microsoft_Network_privateDnsZones_SOA_privatelinkdnszonesname 'Microsoft.Network/privateDnsZones/SOA@2018-09-01' = {
  parent: privatelinkdnszonesname_resource
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

resource privatelinkdnszonesname_we7g5e376t5mi 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2018-09-01' = {
  parent: privatelinkdnszonesname_resource
  name: 'we7g5e376t5mi'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', virtualnetworkname)
    }
  }
}

resource sqlendpointname_resource 'Microsoft.Network/privateEndpoints@2022-07-01' = {
  name: sqlendpointname
  location: resourceGroup().location
  properties: {
    privateLinkServiceConnections: [
      {
        name: sqlendpointname
        id: '${resourceId('Microsoft.Network/privateEndpoints', sqlendpointname)}/privateLinkServiceConnections/${sqlendpointname}'
        properties: {
          privateLinkServiceId: sqlservername_resource.id
          groupIds: [
            'sqlServer'
          ]
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    manualPrivateLinkServiceConnections: []
    customNetworkInterfaceName: '${sqlendpointname}-nic'
    subnet: {
      id: '${resourceId('Microsoft.Network/virtualNetworks', virtualnetworkname)}/subnets/Subnet-3'
    }
    ipConfigurations: []
    customDnsConfigs: []
  }
}

resource sqlservername_default 'Microsoft.Sql/servers/connectionPolicies@2022-08-01-preview' = {
  parent: sqlservername_resource
  name: 'default'
  location: 'eastus'
  properties: {
    connectionType: 'Default'
  }
}

resource sqlservername_sqldbname 'Microsoft.Sql/servers/databases@2022-08-01-preview' = {
  parent: sqlservername_resource
  name: '${sqldbname}'
  location: resourceGroup().location
  sku: {
    name: 'GP_S_Gen5'
    tier: 'GeneralPurpose'
    family: 'Gen5'
    capacity: 4
  }
  kind: 'v12.0,user,vcore,serverless'
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: 34359738368
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    zoneRedundant: false
    readScale: 'Disabled'
    autoPauseDelay: 60
    requestedBackupStorageRedundancy: 'Local'
    minCapacity: 1
    maintenanceConfigurationId: '/subscriptions/463f0dcf-6d32-417d-9ce1-adf76e1c6dd9/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_Default'
    isLedgerOn: false
    preferredEnclaveType: 'Default'
  }
}

resource sqlendpointname_default 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  name: '${sqlendpointname}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-database-windows-net'
        properties: {
          privateDnsZoneId: privatelinkdnszonesname_resource.id
        }
      }
    ]
  }
  dependsOn: [
    sqlendpointname_resource
  ]
}

resource keyvaultname_SQLDBAdmin 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  name: '${keyvaultname}/SQLDBAdmin'
  location: resourceGroup().location
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: reference(sqlservername, '2022-05-01-preview', 'Full').properties.administratorLogin
  }
  dependsOn: [
    sqlservername_resource
    sqlservername_sqldbname
  ]
}

resource keyvaultname_SQLDBConnString 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  name: '${keyvaultname}/SQLDBConnString'
  location: resourceGroup().location
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: 'Server=tcp:${reference(sqlservername, '2022-05-01-preview', 'Full').properties.fullyQualifiedDomainName},1433;Initial Catalog=${sqldbname};Persist Security Info=False;User ID=${reference(sqlservername, '2022-05-01-preview', 'Full').properties.administratorLogin};Password=${adminpassword};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;'
  }
  dependsOn: [
    sqlservername_resource
    sqlservername_sqldbname
  ]
}

resource KeyVaultName_SQLDBPassword 'Microsoft.KeyVault/vaults/secrets@2022-11-01' = {
  name: '${keyvaultname}/SQLDBPassword'
  location: resourceGroup().location
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: adminpassword
  }
  dependsOn: [
    sqlservername_resource
    sqlservername_sqldbname
  ]
}
