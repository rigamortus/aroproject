param name string
param kind string
param keyVault string = 'pullkv'
param connectionStringKey string = 'AZURE-COSMOS-CONNECTION-STRING'
param location string
param locations array
param capability string
param serverversion string
output name string = cosmosAccount.name

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-09-01-preview' = {
  name: name
  kind: kind
  location: location
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [ for loc in locations: {
        isZoneRedundant: loc.zone
        failoverPriority: loc.failover
        locationName: loc.name
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    capabilities: [
      {
        name: capability
      }
    ]
    enableAutomaticFailover: false
    apiProperties: (kind == 'MongoDB') ? { serverVersion: serverversion } : {}
  }
}


resource cosmosConnectionString 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  parent: kv
  name: connectionStringKey
  properties: {
    value: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVault
}
