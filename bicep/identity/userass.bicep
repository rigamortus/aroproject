param name string
output uaidentity string = identity.properties.principalId
resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: name
  location: resourceGroup().location
}

