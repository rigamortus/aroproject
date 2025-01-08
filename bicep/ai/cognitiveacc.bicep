param name string
param kind string
param customsub string
param acls object
param sku object
param location string

resource openai 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: name
  location: location
  sku: sku
  kind: kind
  properties: {
    customSubDomainName: customsub
    publicNetworkAccess: 'Enabled'
    networkAcls: acls
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output aiaccount string = openai.name
output endpoint string = openai.properties.endpoint
output id string = openai.id
