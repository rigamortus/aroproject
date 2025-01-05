param name string
param addressprefix string
param vnetName string
param nsgid string


resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
  name: vnetName
}


resource arosubnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  parent: vnet
  name: name
  properties: { 
    addressPrefix: addressprefix
    serviceEndpoints: name == 'acr-kv-subnet' ? [
      {
        service: 'Microsoft.KeyVault'
      }
      {
        service: 'Microsoft.ContainerRegistry'
      }
    ] : [
      {
        service: 'Microsoft.ContainerRegistry'
      }
    ]
    privateLinkServiceNetworkPolicies: 'Disabled'
    networkSecurityGroup: contains(['master-subnet', 'worker-subnet'], name) ? null : {
      id: nsgid
    }
  }
}

output id string = arosubnet.id
