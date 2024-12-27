param name string
//param model object
//param raiPolicyName string
param sku object
param aiaccount string
param version string
param format string
resource aiacc 'Microsoft.CognitiveServices/accounts@2024-10-01' existing = {
  name: aiaccount
}


resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = {
  parent: aiacc
  name: name
  properties: {
    model: {
      format: format
      name: name
      version: version
    }
    //raiPolicyName: empty(raiPolicyName) ? null : raiPolicyName
  }
  sku: sku
}
