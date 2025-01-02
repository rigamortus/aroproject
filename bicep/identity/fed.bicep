param uaname string
param namespace string
param serviceAccountName string
param aropr string

resource uaid 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' existing = {
  name: uaname
}
resource federatedCredential 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: 'kubernetes-federated-credential'
  parent: uaid
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: aropr
    subject: 'system:serviceaccount:${namespace}:${serviceAccountName}'
  }
}
