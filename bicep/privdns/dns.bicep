param name string
param location string

resource privdns 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: name
  location: location
}

output privdnsname string = privdns.name
