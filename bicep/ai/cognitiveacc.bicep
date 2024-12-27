param name string
param kind string
param customsub string
param acls object
param sku object
param location string
output aiaccount string = openai.name
output endpoint string = openai.properties.endpoint
output id string = openai.id

resource openai 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: name
  location: location
  kind: kind
  properties: {
    customSubDomainName: customsub
    publicNetworkAccess: 'Enabled'
    networkAcls: acls
  }
  sku: sku
}
