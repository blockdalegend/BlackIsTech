param name string

resource name_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: resourceGroup().location
  properties: {}
}