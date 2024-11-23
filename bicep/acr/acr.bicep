param name string
param sku string
param adminuser bool
param access string
param location string
param bypass string
param networkRuleSet object
output acrname string = aroacr.id

resource aroacr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties:{
    adminUserEnabled: adminuser
    publicNetworkAccess: access
    networkRuleBypassOptions: bypass
    networkRuleSet: {
      defaultAction: networkRuleSet.default
      ipRules: [ for rule in networkRuleSet.ipRules: {
        value: rule.value
        action: rule.action
      }]
    }
  }
}
