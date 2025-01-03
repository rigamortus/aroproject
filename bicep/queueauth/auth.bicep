param queueauthname string
param queuenm string
//param name string = 'aro-sender-secret'
//param keyVault string
output queueauthnm string = queueauthentication.name
output queueauthid string = queueauthentication.id
//output queueauthkey string = queueauthentication.listKeys().primaryKey

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


// module sendersecretModule '../kv/kvsecret.bicep' = {
//   name: 'deploy-${name}'
//   params: {
//     name: 'senderKey'
//     secretValue: queueauthentication.listKeys().primaryKey
//     keyVault: keyVault
//   }
// }
