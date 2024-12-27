metadata description = 'Creates a Log Analytics workspace.'
param name string
param location string = 'northeurope'
param tags object = {}
output logid string = logAnalytics.id

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: name
  location: location
  tags: tags
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}

output name string = logAnalytics.name
