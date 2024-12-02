param name string = 'aro-listener-secret'
param location string
param sku string

output svcbus string = serviceBus.name

resource serviceBus 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
}

module listenersecretModule '../kv/kvsecret.bicep' = {
  name: 'deploy-${name}'
  params: {
    name: name
    secretValue: serviceBus.listKeys().primaryKey
  }
}
