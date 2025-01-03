var deploy = 'true'
param name string
param location string
param visibility string
//param rgid string
param version string
param arodomain string
param ingressProfiles array
param masterSubnetId string
param vm string
param workerProfiles array
param podcidr string
param servicecidr string
param clientid string
@secure()
param clientsecret string
param workerSubnetId string
@secure()
param pullsecret string
output aroid string = arobicep.id
output aroname string = arobicep.name
output aropr string = arobicep.properties.clusterProfile.domain
output aroissuer string = arobicep.properties.apiserverProfile.url




resource arobicep 'Microsoft.RedHatOpenShift/openShiftClusters@2023-04-01' = if (deploy == 'true') {
  name: name 
  location: location
  properties: {
    apiserverProfile: {
      visibility: visibility
    }
    clusterProfile: {
      resourceGroupId: subscriptionResourceId('Microsoft.Resources/resourceGroups', 'aro-cluster-rg')
      version: version
      domain: arodomain
      pullSecret: pullsecret
      fipsValidatedModules: 'Disabled'
    }
    ingressProfiles: [ for ingress in ingressProfiles: {
      name: ingress.name
      visibility: ingress.visibility        
    }]
    masterProfile: {
      subnetId: masterSubnetId
      vmSize: vm
      encryptionAtHost: 'Disabled'
    }
    workerProfiles: [ for profile in workerProfiles : {
      count: profile.count
      diskSizeGB: profile.disksize
      name: profile.name
      subnetId: workerSubnetId
      vmSize: profile.vmsize
      encryptionAtHost: profile.encryption
    }]
    networkProfile: {
      podCidr: podcidr
      serviceCidr: servicecidr
    }
    servicePrincipalProfile: {
      clientId: clientid
      clientSecret: clientsecret
    }
  }
}
