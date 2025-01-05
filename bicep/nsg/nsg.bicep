param name string
param location string
param securityRules array

resource nsgbicep 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: name
  location: location
  properties: {
    securityRules: [ for rule in securityRules: {
      name: rule.name
      properties: {
        access: rule.access
        direction: rule.direction
        priority: rule.priority
        protocol: rule.protocol
        destinationAddressPrefix: rule.destination
        sourceAddressPrefix: rule.source
        destinationPortRange: rule.destport
        sourcePortRange: rule.sourceport
      }
    }]
  }
}

output nsgid string = nsgbicep.id
