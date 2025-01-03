param rulename string
param svcbusname string
//output svcbuskey string = servicebusauth.listKeys().primaryKey
output svcauthname string = servicebusauth.name

resource existsvcbus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: svcbusname
}

resource servicebusauth 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2024-01-01' = {
  name: rulename
  parent: existsvcbus
  properties: {
    rights: [
      'Listen'
    ]
  }
}
