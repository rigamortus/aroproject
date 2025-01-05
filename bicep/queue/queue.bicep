param queuename string
param svcbusname string

resource existsvcbus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: svcbusname
}

resource svcbusqueue 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  parent: existsvcbus
  name: queuename
}

output namequeue string = svcbusqueue.name
