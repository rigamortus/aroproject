param name string
param location string
output privdnsname string = privdns.name

resource privdns 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: name
  location: location
}
