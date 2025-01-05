param principalId string
//param vnetName string
param roledef string
//param scope any
param principal string
param subscriptionId string = '01865a64-1974-4037-8780-90e5bebf910e'
//param aiaccount string

// resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(subscriptionId, principalId, roledef)
//   scope: vnet
//   properties: {
//     principalId: principalId
//     roleDefinitionId: roledef
//   }
// }

// resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
//   name: vnetName
// }


// resource airole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (roledef=='/subscriptions/01865a64-1974-4037-8780-90e5bebf910e/providers/Microsoft.Authorization/roleDefinitions/5e0bd9bd-7b93-4f28-af87-19fc36ad61bd') {
//   name: guid(subscriptionId, principalId, roledef)
//   //scope: aiacc
//   properties: {
//     principalId: principalId
//     roleDefinitionId: roledef
//   }
// }

// resource aiacc 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
//   name: aiaccount
// }


resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: resourceGroup() //tenant().tenantId
  name: guid(subscriptionId, principalId, roledef)
  properties: {
    principalId: principalId
    roleDefinitionId: roledef
    principalType: principal
  }
}
