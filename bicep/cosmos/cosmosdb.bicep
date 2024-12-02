param containers array
param name string
param id string

resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-09-01-preview' = {
  name: name
  properties: {
    resource: {
      id: id
    }
  }
  resource comsmoscontainers 'containers' = [for container in containers: {
    name: container.name
    properties: {
      resource: {
        id: container.id
        partitionKey: {
          paths: [
            container.partition
          ]
        }
      }
      options: {}
    }    
  }]
}
