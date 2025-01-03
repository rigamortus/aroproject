param name string
param keyVault string
//param svcbusid string
param authRuleId string
param contentType string = 'string'
//@secure()
//param secretValue string

param enabled bool = true
param exp int = 0
param nbf int = 0

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVault
}

resource authRule 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2024-01-01' existing = {
  name: authRuleId
}
resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2024-04-01-preview' = {
  name: name
  parent: kv
  properties: {
    attributes: {
      enabled: enabled
      exp: exp
      nbf: nbf == 0 ? null : nbf
    }
    contentType: contentType
    //value: secretValue
    value: authRule.listKeys().primaryKey
  }
}
