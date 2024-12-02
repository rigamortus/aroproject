param queueauthname string
param queuenm string
param name string = 'aro-sender-secret'
output queueauthnm string = queueauthentication.name

resource parentqueue 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' existing = {
  name: queuenm
}
resource queueauthentication 'Microsoft.ServiceBus/namespaces/queues/authorizationRules@2024-01-01' = {
  name: queueauthname
  parent: parentqueue
  properties: {
    rights: [
      'Send'
    ]
  }
}


module sendersecretModule '../kv/kvsecret.bicep' = {
  name: 'deploy-${name}'
  params: {
    name: name
    secretValue: queueauthentication.listKeys().primaryKey
  }
}
