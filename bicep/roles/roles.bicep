param principalId string
param vnetName string
param roledef string
param subscriptionId string = '01865a64-1974-4037-8780-90e5bebf910e'

resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscriptionId, principalId, roledef)
  scope: vnet
  properties: {
    principalId: principalId
    roleDefinitionId: roledef
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
  name: vnetName
}
