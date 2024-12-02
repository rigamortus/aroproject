param cosmosacc string
param principalId string
param roleDefinitionId string

resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2024-09-01-preview' existing = {
  name: cosmosacc
}

resource cosmosassign 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2024-09-01-preview' = {
  name: guid(roleDefinitionId, principalId, cosmosAccount.id)
  parent: cosmosAccount
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    scope: cosmosAccount.id
  }
}
