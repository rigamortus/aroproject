param name string
param id string
param collections array
//param throughput int

resource aromongo 'Microsoft.DocumentDB/databaseAccounts/mongodbDatabases@2024-09-01-preview' = {
  name: name
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    resource: {
      id: id
    }
    // options: {
    //   throughput: throughput
    // }
  }
  resource list 'collections' = [ for collection in collections: {
    name: collection.name
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      resource: {
        id: collection.id
        shardKey: {
          _id: collection.shard
        }
        indexes: [
          {
            key: {
              keys: [
                collection.index
              ]
            }
          }
        ]
      }
    }
  }]
}

output endpoint string = 'mongodb://cosmos-${name}.mongo.cosmos.azure.com:10255/?retryWrites=false'
