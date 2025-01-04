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
param mongoconfig array
param cognitive array
//param cosmosass array
param identity array
//param grafroles array
param airoles array
param fedcred array
param aimodel array
param monitors array
param observability array
param loganalytics array
//param location string = 'northeurope'
param subscriptionId string = '01865a64-1974-4037-8780-90e5bebf910e'
param keyVaultName string = 'pullkv'
//param secretName string = 'pullsecret'
//param client string = 'client'
param grafroles array = [
  {
    name: 'aro-grafana'
    roledef: '/subscriptions/01865a64-1974-4037-8780-90e5bebf910e/providers/Microsoft.Authorization/roleDefinitions/b0d8363b-8ddd-447d-831f-62ca05bff136'
    principal: 'ServicePrincipal'
  }
]
param principalId string = '4c8fc9f7-21c3-4d54-a704-58b2a06dbb3c'
param grafanaAdminRole string = '/subscriptions/01865a64-1974-4037-8780-90e5bebf910e/providers/Microsoft.Authorization/roleDefinitions/22926164-76b3-42b3-bc55-97df8dab3e41'
var nsgid = nsgModule[0].outputs.nsgid
output masterSubnetId string = subnetModule1.outputs.id
output vnetname string = vnetModule[0].outputs.vnetname
var vnetName = vnetModule[0].outputs.vnetname
var masterSubnetId = subnetModule1.outputs.id
var workerSubnetId = subnetModule2.outputs.id
var acrkvSubnetId = subnetModule3.outputs.id
var acrid = acrModule[0].outputs.acrname
var kvid = keyvaultModule[0].outputs.kvid
var vnetid = vnetModule[0].outputs.vnetid
var acrzone = privdnsModule[1].outputs.privdnsname
var kvzone = privdnsModule[0].outputs.privdnsname
var svcbusname = svcbusModule[0].outputs.svcbus
var queuenm = queueModule[0].outputs.namequeue
var cosmosacc = cosmosaccModule[0].outputs.name
//var aropr = aroModule[0].outputs.aropr
//var aroid = aroModule[0].outputs.aroid
var aroname = aroModule[0].outputs.aroname
var uaidentity = userassModule[0].outputs.uaidentity
var aiaccount = aiaccountModule[0].outputs.aiaccount
var logid = logModule[0].outputs.logid
var logname = logModule[0].outputs.name
var monitorid = monitorModule[0].outputs.id
//var monitorname = monitorModule[0].outputs.name
var grafanaid = observModule[0].outputs.grafanaid
var uaname = userassModule[0].outputs.uaname
var aroissuer = aroModule[0].outputs.aroissuer
var kvName = keyvaultModule[0].outputs.keyVaultName
//var svcauthid = svcauthModule[0].outputs.svcauthname

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
      location: vnet.location
      tags: vnet.tags
      addressprefix: vnet.addressprefix
    }
  }
]

// module subnetModule './subnets/subnet.bicep' = [
//   for subnet in subnets: {
//     name: 'deploy-${subnet.name}'
//     scope: resourceGroup(subscriptionId, subnet.rg)
//     dependsOn: vnetModule
//     params: {
//       name: subnet.name
//       vnetName: vnetName
//       addressprefix: subnet.addressprefix
//       nsgid: nsgid
//     }
//   }
// ]

module subnetModule1 './subnets/subnet.bicep' = if(subnets[0] != null) {
  name: 'deploy-${subnets[0].name}'
  scope: resourceGroup(subscriptionId, subnets[0].rg)
  dependsOn: [vnetModule]
  params: {
    name: subnets[0].name
    vnetName: vnetName
    addressprefix: subnets[0].addressprefix
    nsgid: nsgid
  }
}

module subnetModule2 './subnets/subnet.bicep' = if(subnets[1] != null) {
  name: 'deploy-${subnets[1].name}'
  scope: resourceGroup(subscriptionId, subnets[1].rg)
  dependsOn: [subnetModule1]
  params: {
    name: subnets[1].name
    vnetName: vnetName
    addressprefix: subnets[1].addressprefix
    nsgid: nsgid
  }
}

module subnetModule3 './subnets/subnet.bicep' = if(subnets[2] != null) {
  name: 'deploy-${subnets[2].name}'
  scope: resourceGroup(subscriptionId, subnets[2].rg)
  dependsOn: [subnetModule2]
  params: {
    name: subnets[2].name
    vnetName: vnetName
    addressprefix: subnets[2].addressprefix
    nsgid: nsgid
  }
}

module subnetModule4 './subnets/subnet.bicep' = if(subnets[3] != null) {
  name: 'deploy-${subnets[3].name}'
  scope: resourceGroup(subscriptionId, subnets[3].rg)
  dependsOn: [subnetModule3]
  params: {
    name: subnets[3].name
    vnetName: vnetName
    addressprefix: subnets[3].addressprefix
    nsgid: nsgid
  }
}


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
    dependsOn: [subnetModule4]
    scope: resourceGroup(subscriptionId, osc.rg)
    params: {
      name: osc.name
      location: osc.location
      visibility: osc.visibility
      //rgid: osc.rgid
      pullsecret: kv.getSecret('pullsecret')
      version: osc.version
      arodomain: osc.arodomain
      ingressProfiles: osc.ingressProfiles
      workerProfiles: osc.workerProfiles
      podcidr: osc.podcidr
      servicecidr: osc.servicecidr
      vm: osc.vm
      workerSubnetId: workerSubnetId
      masterSubnetId: masterSubnetId
      clientid: osc.clientid
      clientsecret: kv.getSecret('client')
    }
  }
]

module roleModule './roles/roles.bicep' = [
  for role in roles: {
    name: 'deploy-${role.name}'
    //scope: role.scope
    params: {
      principalId: role.principalId
      roledef: role.roledef
      principal: role.principal
      //vnetName: vnetName
      //aiaccount: aiaccount
    }
  }
]

module privendpModule './privatendpoint/privendp.bicep' = [
  for privend in privatendpoints: {
    name: 'deploy-${privend.name}'
    params: {
      name: privend.name
      location: privend.location
      privateLinkServiceConnections: privend.privateLinkServiceConnections
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
      //listenerame: 'listenersecret'
      //keyVault: kvName
    }
  }
]

module svcauthModule './svcbusauth/svcbusauth.bicep' = [
  for auth in svcauth: {
    name: 'deploy-${auth.rulename}'
    dependsOn: svcbusModule
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
      //keyVault: kvName
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

module mongoModule './mongo/mongo.bicep' = [for mongo in mongoconfig: {
  name: 'deploy-${mongo.name}'
  params: {
    name: '${cosmosacc}/${mongo.name}'
    collections: mongo.collections
    id: mongo.id
    //throughput: mongo.throughput
  } 
}]
module userassModule './identity/userass.bicep' = [
  for ua in identity: {
    name: 'deploy-${ua.name}'
    dependsOn: aroModule
    params: {
      name: ua.name
      location: ua.location
    }
  }
]

module fedcredModule './identity/fed.bicep' = [
  for fed in fedcred: {
    name: 'deploy-${fed.name}'
    dependsOn: userassModule
    params: {
      aropr: aroissuer
      namespace: fed.ns
      serviceAccountName: fed.sacc
      uaname: uaname
    }
  }
]

module aiaccountModule './ai/cognitiveacc.bicep' = [for acc in cognitive: {
  name: 'deploy-${acc.name}'
  params: {
    name: acc.name
    location: acc.location
    sku: acc.sku
    kind: acc.kind
    acls: acc.acls
    customsub: acc.customsub
  }
}]

@batchSize(1)
module aimodelModule './ai/openai.bicep' = [ for model in aimodel: {
  name: 'deploy-${model.name}'
  params: {
    name: model.name
    //model: model.model
    format: model.model.format
    version: model.model.version
    aiaccount: aiaccount
    sku: model.sku
    //raiPolicyName: model.rai
  }
}]

module airole './roles/roles.bicep' = [ for airole in airoles: {
  name: 'deploy-${airole.name}'
  dependsOn: userassModule
  params: {
    principalId: uaidentity
    roledef: airole.roledef
    principal: airole.principal
  }
}]


module logModule './monitor/log.bicep' = [for log in loganalytics: {
  name: 'deploy-${log.name}'
  params: {
    name: log.name
    location: log.location
  }  
}]

module monitorModule './monitor/monitor.bicep' = [for monitor in monitors: {
  name: 'deploy-${monitor.name}'
  params: {
    name: monitor.name
    location: monitor.location
  }  
}]

module observModule './monitor/observability.bicep' = [for obs in observability: {
  name: 'deploy-${obs.clusterName}'
  params: {
    location: obs.location
    //aroclusterid: aroid
    clusterName: aroname
    grafaname: obs.grafaname
    logAnalyticsId: logid
    logAnalyticsName: logname
    monitorId: monitorid
    //monitorName: monitorname
    name: obs.name
    nodename: obs.nodename
  } 
}]

module grafanaMonitorReaderRole './roles/roles.bicep' = [ for grafrole in grafroles: {
  name: 'deploy-${grafrole.name}'
  params: {
    principalId: grafanaid
    roledef: grafrole.roledef
    principal: grafrole.principal
  }
}]

module roleAssignmentForMe './roles/roles.bicep' = {
  name: 'grafanaRoleAssignmentForMe'
  params: {
    principalId: principalId
    roledef: grafanaAdminRole
    principal: 'User'
  }
}

module sendersecretModule './kv/kvsecret.bicep' = {
  name: 'deploy-senderKey'
  params: {
    name: 'senderKey'
    authRuleId: queueauthModule[0].outputs.queueauthnm
    keyVault: kvName
    enabled: true
    contentType: 'string'
    exp: 0
    nbf: 0
  }
}

// resource svcAuth 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2024-01-01' existing = {
//   name: svcauthid
//   dependsOn: svcauthModule
// }

//var secretValue = svcAuth.listKeys().primaryKey
module listenersecretModule './kv/kvsecret.bicep' = {
  name: 'deploy-listenerkey'
  dependsOn: [sendersecretModule]
  params: {
    name: 'listenerkey'
    //secretValue: svcauthModule[0].outputs.svcbuskey
    //secretValue: svcAuth.listKeys().primaryKey
    //secretValue: secretValue
    authRuleId: svcauthModule[0].outputs.svcauthname
    keyVault: kvName
    enabled: true
    contentType: 'string'
    exp: 0
    nbf: 0
  }
}
