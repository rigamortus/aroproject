param name string
param location string
param acrkvSubnetId string
param acrid string
param kvid string
param privateLinkServiceConnections array

resource aroprivendp 'Microsoft.Network/privateEndpoints@2024-03-01'= {
  name: name
  location: location
  properties: {
    subnet: {
      id: acrkvSubnetId
    }
    privateLinkServiceConnections: [ for link in privateLinkServiceConnections : {
        name: link.name
        properties: {
          groupIds: [
            link.gid
          ]
          privateLinkServiceId: name == 'acrendpoint' ? acrid : kvid
        }
      }
    ]
  }
}
