param vnets array
param subnets array
param keyvaults array
param acrs array
param nsgs array
param aro array
param roles array
param privdns array
param privlink array
param privatendpoints array
param svcbus array
param svcauth array
param queue array
param queueauth array
param cosmosaccount array
param cosmosdb array
//param cosmosass array
param identity array
param fedcred array
param location string = 'north europe'
param subscriptionId string = '01865a64-1974-4037-8780-90e5bebf910e'
param keyVaultName string = 'pullkv'
param secretName string = 'pullsecret'
var nsgid = nsgModule[0].outputs.nsgid
output masterSubnetId string = subnetModule[0].outputs.id
output vnetname string = vnetModule[0].outputs.vnetname
var vnetName = vnetModule[0].outputs.vnetname
var masterSubnetId = subnetModule[0].outputs.id
var workerSubnetId = subnetModule[1].outputs.id
var acrkvSubnetId = subnetModule[2].outputs.id
var acrid = acrModule[0].outputs.acrname
var kvid = keyvaultModule[0].outputs.kvid
var vnetid = vnetModule[0].outputs.vnetid
var acrzone = privdnsModule[1].outputs.privdnsname
var kvzone = privdnsModule[0].outputs.privdnsname
var svcbusname = svcbusModule[0].outputs.svcbus
var queuenm = queueModule[0].outputs.namequeue
var cosmosacc = cosmosaccModule[0].outputs.name
var aropr = aroModule[0].outputs.aropr
var uaidentity = userassModule[0].outputs.uaidentity

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
  scope: resourceGroup(subscriptionId, 'myrg')
}

module vnetModule './vnets/vnet.bicep' = [
  for vnet in vnets: {
    name: 'deploy-${vnet.name}'
    scope: resourceGroup(subscriptionId, vnet.rg)
    params: {
      name: vnet.name
      location: location
      tags: vnet.tags
      addressprefix: vnet.addressprefix
    }
  }
]

module subnetModule './subnets/subnet.bicep' = [
  for subnet in subnets: {
    name: 'deploy-${subnet.name}'
    scope: resourceGroup(subscriptionId, subnet.rg)
    dependsOn: vnetModule
    params: {
      name: subnet.name
      vnetName: vnetName
      addressprefix: subnet.addressprefix
      nsgid: nsgid
    }
  }
]

module keyvaultModule './kv/kv.bicep' = [
  for kv in keyvaults: {
    name: 'deploy-${kv.name}'
    scope: resourceGroup(subscriptionId, kv.rg)
    params: {
      name: kv.name
      accessPolicies: kv.accessPolicies
      diskencrypt: kv.diskencrypt
      location: kv.location
      networkAcls: kv.networkAcls
      purge: kv.purge
      sku: kv.sku
      tenantId: kv.tenantId
    }
  }
]

module acrModule './acr/acr.bicep' = [
  for acr in acrs: {
    name: 'deploy-${acr.name}'
    scope: resourceGroup(subscriptionId, acr.rg)
    params: {
      name: acr.name
      location: acr.location
      sku: acr.sku
      adminuser: acr.adminuser
      access: acr.access
      bypass: acr.bypass
      networkRuleSet: acr.networkRuleSet
    }
  }
]

module nsgModule './nsg/nsg.bicep' = [
  for nsg in nsgs: {
    name: 'deploy-${nsg.name}'
    scope: resourceGroup(subscriptionId, nsg.rg)
    params: {
      name: nsg.name
      location: nsg.location
      securityRules: nsg.securityRules
    }
  }
]

module aroModule './aro/aro.bicep' = [
  for osc in aro: {
    name: 'deploy-${osc.name}'
    scope: resourceGroup(subscriptionId, osc.rg)
    params: {
      name: osc.name
      location: osc.location
      visibility: osc.visibility
      rgid: osc.rgid
      pullsecret: kv.getSecret(secretName)
      version: osc.version
      arodomain: osc.arodomain
      ingressProfiles: osc.ingressProfiles
      workerProfiles: osc.workerProfiles
      podcidr: osc.podcidr
      servicecidr: osc.servicecidr
      vm: osc.vm
      workerSubnetId: workerSubnetId
      masterSubnetId: masterSubnetId
    }
  }
]

module roleModule './roles/roles.bicep' = [
  for role in roles: {
    name: 'deploy-${role.name}'
    params: {
      principalId: role.principalId
      roledef: role.roledef
      subscriptionId: subscriptionId
      vnetName: vnetName
    }
  }
]

module privendpModule './privatendpoint/privendp.bicep' = [
  for privend in privatendpoints: {
    name: 'deploy-${privend.name}'
    params: {
      name: privend.name
      location: privend.location
      privateLinkServiceConnections: privend.privatelink
      acrkvSubnetId: acrkvSubnetId
      acrid: acrid
      kvid: kvid
    }
  }
]

module privdnsModule './privdns/dns.bicep' = [
  for dns in privdns: {
    name: 'deploy-${dns.name}'
    params: {
      name: dns.name
      location: dns.location
    }
  }
]

module privdnslink './privlink/link.bicep' = [
  for link in privlink: {
    name: 'deploy-${link.name}'
    dependsOn: privdnsModule
    params: {
      name: link.name
      location: link.location
      vnetid: vnetid
      acrzone: acrzone
      kvzone: kvzone
    }
  }
]

module svcbusModule './servicebus/svcbus.bicep' = [
  for bus in svcbus: {
    name: 'deploy-${bus.name}'
    params: {
      name: bus.name
      location: bus.location
      sku: bus.sku
    }
  }
]

module svcauthModule './svcbusauth/svcbusauth.bicep' = [
  for auth in svcauth: {
    name: 'deploy-${auth.rulename}'
    params: {
      rulename: auth.rulename
      svcbusname: svcbusname
    }
  }
]

module queueModule './queue/queue.bicep' = [
  for svcqueue in queue: {
    name: 'deploy-${svcqueue.name}'
    dependsOn: svcbusModule
    params: {
      queuename: svcqueue.name
      svcbusname: svcbusname
    }
  }
]

module queueauthModule './queueauth/auth.bicep' = [
  for auth in queueauth: {
    name: 'deploy-${auth.name}'
    dependsOn: queueModule
    params: {
      queueauthname: auth.name
      queuenm: '${svcbusname}/${queuenm}'
    }
  }
]
module cosmosaccModule './cosmos/cosmosacc.bicep' = [
  for acc in cosmosaccount: {
    name: 'deploy-${acc.name}'
    params: {
      name: acc.name
      location: acc.location
      kind: acc.kind
      capability: acc.capability
      locations: acc.locations
      serverversion: acc.serverversion
    }
  }
]

module cosmosdbModule './cosmos/cosmosdb.bicep' = [
  for db in cosmosdb: {
    name: 'deploy-${db.name}'
    params: {
      name: '${cosmosacc}/${db.name}'
      containers: db.containers
      id: db.id
    }
  }
]

// module cosmosassModule './cosmos/cosmosassign.bicep' = [ for ass in cosmosass: {
//   name: 'deploy-${ass.name}'
//   params: {
//     cosmosacc: cosmosacc
//     principalId: ass.principalId
//     roleDefinitionId: ass.roledef
//   }
// }]

module userassModule './identity/userass.bicep' = [
  for ua in identity: {
    name: 'deploy-${ua.name}'
    params: {
      name: ua.name
    }
  }
]

module fedcredModule './identity/fed.bicep' = [
  for fed in fedcred: {
    name: 'deploy-${fed.name}'
    params: {
      aropr: aropr
      namespace: fed.ns
      serviceAccountName: fed.sacc
      uaidentity: uaidentity
    }
  }
]
