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

resource kv 'Microsoft.KeyVault/vaults@2024-04-01-preview' existing = {
  name: keyVaultName
  scope: resourceGroup(subscriptionId, 'myrg')
}


module vnetModule './vnets/vnet.bicep' = [ for vnet in vnets: {
  name: 'deploy-${vnet.name}'
  scope: resourceGroup(subscriptionId, vnet.rg)
  params: {
    name: vnet.name
    location: location
    tags: vnet.tags
    addressprefix: vnet.addressprefix
  }
}]

module subnetModule './subnets/subnet.bicep' = [ for subnet in subnets: {
  name: 'deploy-${subnet.name}'
  scope: resourceGroup(subscriptionId, subnet.rg)
  dependsOn: vnetModule
  params: {
    name: subnet.name
    vnetName: vnetName
    addressprefix: subnet.addressprefix
    nsgid: nsgid
  }
}]

module keyvaultModule './kv/kv.bicep' = [ for kv in keyvaults: {
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
}]

module acrModule './acr/acr.bicep' = [ for acr in acrs: {
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
}]

module nsgModule './nsg/nsg.bicep' = [ for nsg in nsgs: {
  name: 'deploy-${nsg.name}'
  scope: resourceGroup(subscriptionId, nsg.rg)
  params: {
    name: nsg.name
    location: nsg.location
    securityRules: nsg.securityRules   
  }
}]

module aroModule './aro/aro.bicep' = [ for osc in aro: {
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
}]

module roleModule './roles/roles.bicep' = [ for role in roles: {
  name: 'deploy-${role.name}'
  params: {
    principalId: role.principalId
    roledef: role.roledef
  } 
}]

module privendpModule './privatendpoint/privendp.bicep' = [ for privend in privatendpoints : {
  name: 'deploy-${privend.name}'
  params: {
    name: privend.name
    location: privend.location
    privateLinkServiceConnections: privend.privatelink
    acrkvSubnetId: acrkvSubnetId
    acrid: acrid
    kvid: kvid
  }
}]

module privdnsModule './privdns/dns.bicep' = [ for dns in privdns : {
  name: 'deploy-${dns.name}'
  params: {
    name: dns.name
    location: dns.location
  }
}]

module privdnslink './privlink/link.bicep' = [ for link in privlink : {
  name: 'deploy-${link.name}'
  dependsOn: privdnsModule
  params: {
    name: link.name
    location: link.location
    vnetid: vnetid
    acrzone: acrzone
    kvzone: kvzone
  }
}]
