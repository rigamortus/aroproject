param name string
param kind string
param keyVault string = 'pullkv'
param connectionStringKey string = 'AZURE-COSMOS-CONNECTION-STRING'
param location string
param locations array
param capability array
param serverversion string

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVault
}

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = {
  name: name
  location: location
  kind: kind
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
    capabilities: [ for cap in capability: {
        name: cap.name
      }
    ]
    enableAutomaticFailover: false
    apiProperties: (kind == 'MongoDB') ? { serverVersion: serverversion } : {}
  }
}


resource cosmosConnectionString 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  parent: kv
  name: connectionStringKey
  properties: {
    value: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}

output name string = cosmosAccount.name
output connectionStringKey string = connectionStringKey
output endpoint string = cosmosAccount.properties.documentEndpoint
output id string = cosmosAccount.id
