param name string
param location string
param sku string
//param listenerame string
//param keyVault string
output svcbus string = serviceBus.name

resource serviceBus 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
}

// module listenersecretModule '../kv/kvsecret.bicep' = {
//   name: 'deploy-${listenerame}'
//   params: {
//     name: listenerame
//     secretValue: serviceBus.listKeys().primaryKey
//      keyVault: keyVault
//   }
// }
