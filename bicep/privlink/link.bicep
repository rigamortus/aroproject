param name string
param location string
param vnetid string
param acrzone string
param kvzone string

resource acr 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: acrzone
}

resource kv 'Microsoft.Network/privateDnsZones@2024-06-01' existing = {
  name: kvzone
}

resource linkdns 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (name == 'acrvnetlink') {
  name: name
  location: location
  properties: {
    virtualNetwork: {
      id: vnetid
    }
    registrationEnabled: false
  }
  parent: acr
}

resource kvlinkdns 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2024-06-01' = if (name == 'kv-vnet-link') {
  name: name
  location: location
  properties: {
    virtualNetwork: {
      id: vnetid
    }
    registrationEnabled: false
  }
  parent: kv
}
