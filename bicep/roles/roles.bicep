param principalId string
param roledef string
param subscriptionId string = '01865a64-1974-4037-8780-90e5bebf910e'
resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscriptionId, principalId, roledef)
  properties: {
    principalId: principalId
    roleDefinitionId: roledef
  }
}
