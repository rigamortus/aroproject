param queuename string
param svcbusname string
output namequeue string = svcbusqueue.name
resource existsvcbus 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: svcbusname
}

resource svcbusqueue 'Microsoft.ServiceBus/namespaces/queues@2024-01-01' = {
  name: queuename
  parent: existsvcbus
}
