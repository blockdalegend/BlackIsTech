param virtualnetworkname string

resource virtualnetworkname_Subnet_1 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${virtualnetworkname}/Subnet-1'
  properties: {
    addressPrefix: '10.0.0.0/24'
    serviceEndpoints: [
      {
        service: 'Microsoft.Storage'
        locations: [
          resourceGroup().location
          'westus'
          'westus3'
        ]
      }
    ]
    delegations: [
      {
        name: 'Microsoft.Web.serverFarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
      }
    ]
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualnetworkname_resource
  ]
}

resource virtualnetworkname_Subnet_2 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${virtualnetworkname}/Subnet-2'
  properties: {
    addressPrefix: '10.0.1.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualnetworkname_resource
  ]
}

resource virtualnetworkname_Subnet_3 'Microsoft.Network/virtualNetworks/subnets@2022-07-01' = {
  name: '${virtualnetworkname}/Subnet-3'
  properties: {
    addressPrefix: '10.0.2.0/24'
    serviceEndpoints: []
    delegations: []
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
  dependsOn: [
    virtualnetworkname_resource
  ]
}

resource virtualnetworkname_resource 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: virtualnetworkname
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'Subnet-2'
        properties: {
          addressPrefix: '10.0.1.0/24'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'Subnet-3'
        properties: {
          addressPrefix: '10.0.2.0/24'
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
      {
        name: 'Subnet-1'
        properties: {
          addressPrefix: '10.0.0.0/24'
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
              locations: [
                resourceGroup().location
                'westus'
                'westus3'
              ]
            }
          ]
          delegations: [
            {
              name: 'Microsoft.Web.serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
              type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
            }
          ]
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
        type: 'Microsoft.Network/virtualNetworks/subnets'
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
  dependsOn: []
}
