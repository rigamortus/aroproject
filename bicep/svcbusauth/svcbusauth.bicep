param rulename string
param svcbusname string
//output svcbuskey string = servicebusauth.listKeys().primaryKey

resource existsvcbus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: svcbusname
}

resource servicebusauth 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2024-01-01' = {
  parent: existsvcbus
  name: rulename
  properties: {
    rights: [
      'Listen'
    ]
  }
}

output svcauthname string = servicebusauth.name
