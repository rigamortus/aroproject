param cosmosacc string = 'aro-cosmos'
param uaidentity string
param svcbusname string
param subscriptionId string = '01865a64-1974-4037-8780-90e5bebf910e'
param svcbusroledef string ='090c5cfd-751d-490a-894a-3ce6f1109419'
var roledefid = roleDefinition.id

resource serviceBus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: svcbusname
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2022-08-15' existing = {
  name: cosmosacc
}

resource roleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2024-11-15' = {
  parent: cosmos
  name: guid(cosmos.id, cosmosacc, 'sql-role')
  properties: {
    assignableScopes: [
      cosmos.id
    ]
    permissions: [
      {
        dataActions: [
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/*'
        ]
      }
    ]
    roleName: 'Reader Writer'
    type: 'CustomRole'
  }
}


resource cosmosrole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: cosmos 
  name: guid(subscriptionId, uaidentity, roledefid)
  properties: {
    principalId: uaidentity
    roleDefinitionId: roledefid
  }
}

resource svcbusroleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: serviceBus
  name: guid(subscriptionId, uaidentity, svcbusroledef)
  properties: {
    principalId: uaidentity
    roleDefinitionId: svcbusroledef
  }
}



output id string = roleDefinition.id
