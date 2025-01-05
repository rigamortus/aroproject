param name string
param location string

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: name
  location: location
}

output uaidentity string = identity.properties.principalId
output uaname string = identity.name
