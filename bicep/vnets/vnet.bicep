param name string
param location string
param tags object
param addressprefix string
output vnetname string = arovnet.name
output vnetid string = arovnet.id


resource arovnet 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressprefix
      ]
    }
  }
}
