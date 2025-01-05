param name string
param location string
param sku string
param tenantId string
param diskencrypt bool
param purge bool
param networkAcls object
param accessPolicies array

resource keyVault 'Microsoft.KeyVault/vaults@2024-04-01-preview' = {
  name: name
  location: location
  properties: {
    sku: {
      family: 'A'
      name: sku
    }
    tenantId: tenantId
    enabledForDiskEncryption: diskencrypt
    enablePurgeProtection: purge
    networkAcls: {
      bypass: networkAcls.bypass
      defaultAction: networkAcls.defaultAction
      ipRules: [ for rule in networkAcls.ipRules: {
        value: rule.value
      }]
    }
    accessPolicies: [ for policy in accessPolicies: {
      objectId: policy.objectId
      tenantId: policy.tenantId
      permissions: {
        keys: policy.permissions.keys
        secrets: policy.permissions.secrets   
      }
    }
    ]
  }
}

output kvid string = keyVault.id
output keyVaultName string = keyVault.name
