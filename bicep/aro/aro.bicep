param name string
param location string
param visibility string
param rgid string
param version string
param arodomain string
param ingressProfiles array
param masterSubnetId string
param vm string
param workerProfiles array
param podcidr string
param servicecidr string
param workerSubnetId string
@secure()
param pullsecret string
output aroid string = arobicep.id
output aropr string = arobicep.properties.clusterProfile.domain




resource arobicep 'Microsoft.RedHatOpenShift/openShiftClusters@2023-11-22' = {
  name: name
  location: location
  properties: {
    apiserverProfile: {
      visibility: visibility
    }
    clusterProfile: {
      resourceGroupId: rgid
      version: version
      domain: arodomain
      pullSecret: pullsecret
    }
    ingressProfiles: [ for ingress in ingressProfiles: {
      name: ingress.name
      visibility: ingress.visibility        
    }]
    masterProfile: {
      subnetId: masterSubnetId
      vmSize: vm
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
  }
}
