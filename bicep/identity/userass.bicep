param name string
output uaidentity string = identity.properties.principalId
output uaname string = identity.name

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: name
  location: 'northeurope'
}

