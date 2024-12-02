param rulename string
param svcbusname string

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
