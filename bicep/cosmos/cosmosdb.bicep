param containers array
param name string
param id string
param deploy bool = false

resource cosmosdb 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-09-01-preview' =  if (deploy) {
  name: name
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    resource: {
      id: id
    }
  }
  resource comsmoscontainers 'containers' = [for container in containers: {
    name: container.name
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      resource: {
        id: container.id
        partitionKey: {
          paths: [
            container.partition
          ]
        }
      }
    }    
  }]
}


//param deployAzureOpenAI bool = true // Parameter to toggle deployment
// param principalId string // Object ID of the principal to assign the role to
// param cognitiveAccountId string // ID of the Cognitive Services resource

// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (deployAzureOpenAI) {
//   name: guid(cognitiveAccountId, principalId, 'Cognitive Services OpenAI User') // Generate a deterministic GUID for the role assignment
//   properties: {
//     roleDefinitionId: 'Cognitive Services OpenAI User'
//     principalId: principalId
//     //scope: cognitiveAccountId
//   }
// }

// param roleDefinition name string 
