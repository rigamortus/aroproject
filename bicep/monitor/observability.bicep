param location string
param clusterName string
param logAnalyticsId string
param logAnalyticsName string
//param aroclusterid string
param monitorId string
param name string
param nodename string
//param monitorName string
param grafaname string

resource monitorDataCollectionRule 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: 'MSCI-${clusterName}'
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  kind: 'Linux'
  properties: {
    dataSources: {
      extensions: [
        {
          streams: [
            'Microsoft-ContainerInsights-Group-Default'
          ]
          extensionName: 'ContainerInsights'
          extensionSettings: {
            dataCollectionSettings: {
              enableContainerLogV2: true
              interval: '1m'
              namespaceFilteringMode: 'Off'
            }
          }
          name: 'ContainerInsightsExtension'
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsId
          name: logAnalyticsName
        }
      ]
      // monitoringAccounts: [
      //   {
      //     accountResourceId: monitorId
      //     name: monitorName
      //   }
      // ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-ContainerInsights-Group-Default'
        ]
        destinations: [
          logAnalyticsName
          //monitorName
        ]
      }
    ]
  }
}


resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2023-03-11' = {
  name: 'MSProm-${clusterName}'
  location: location
  kind: 'Linux'
  properties: {}
}

// resource aro 'Microsoft.RedHatOpenShift/openShiftClusters@2023-09-04' existing = {
//   name: clusterName
// }

// resource dcrToAro 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
//   name: 'dcr-${clusterName}'
//   scope: aro
//   properties: {
//     dataCollectionRuleId: monitorDataCollectionRule.id
//   }
// }

// resource dcrToAroEndpoint 'Microsoft.Insights/dataCollectionRuleAssociations@2022-06-01' = {
//   name: 'configurationAccessEndpoint'
//   scope: aro
//   properties: {
//     dataCollectionEndpointId: dataCollectionEndpoint.id
//   }
// }

resource grafana 'Microsoft.Dashboard/grafana@2023-09-01' = { 
  name: grafaname
  location: location
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    grafanaIntegrations: {
      azureMonitorWorkspaceIntegrations: [
        {
          azureMonitorWorkspaceResourceId: monitorId
        }
      ]
    }
  }
}


resource monitorPrometheusRuleGroup 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = {
  name: '${nodename}-${clusterName}'
  location: location
  properties:{
    interval: 'PT1M'
    enabled: true
    clusterName: clusterName
    scopes: [monitorId]
    rules: [
      {  
        record: 'instance:node_num_cpu:sum'  
        expression: 'count without (cpu, mode) (node_cpu_seconds_total{job="node",mode="idle"})'  
      }  
      {  
        record: 'instance:node_cpu_utilisation:rate5m'  
        expression: '1 - avg without (cpu) (sum without (mode) (rate(node_cpu_seconds_total{job="node", mode="idle"}[5m])) + sum without (mode) (rate(node_cpu_seconds_total{job="node", mode="iowait"}[5m])) + sum without (mode) (rate(node_cpu_seconds_total{job="node", mode="steal"}[5m])))'  
      }  
      {  
        record: 'instance:node_load1_per_cpu:ratio'  
        expression: 'node_load1{job="node"}/instance:node_num_cpu:sum{job="node"}'  
      }  
      {  
        record: 'instance:node_memory_utilisation:ratio'  
        expression: '1 - ((node_memory_MemAvailable_bytes{job="node"} or (node_memory_Buffers_bytes{job="node"} + node_memory_Cached_bytes{job="node"} + node_memory_MemFree_bytes{job="node"} + node_memory_Slab_bytes{job="node"})) / node_memory_MemTotal_bytes{job="node"})'  
      }  
      {  
        record: 'instance:node_vmstat_pgmajfault:rate5m'  
        expression: 'rate(node_vmstat_pgmajfault{job="node"}[5m])'  
      }  
      {  
        record: 'instance_device:node_disk_io_time_seconds:rate5m'  
        expression: 'rate(node_disk_io_time_seconds_total{job="node", device!=""}[5m])'  
      }  
      {  
        record: 'instance_device:node_disk_io_time_weighted_seconds:rate5m'  
        expression: 'rate(node_disk_io_time_weighted_seconds_total{job="node", device!=""}[5m])'  
      }  
      {  
        record: 'instance:node_network_receive_bytes_excluding_lo:rate5m'  
        expression: 'sum without (device) (rate(node_network_receive_bytes_total{job="node", device!="lo"}[5m]))'  
      }  
      {  
        record: 'instance:node_network_transmit_bytes_excluding_lo:rate5m'  
        expression: 'sum without (device) (rate(node_network_transmit_bytes_total{job="node", device!="lo"}[5m]))'  
      }  
      {  
        record: 'instance:node_network_receive_drop_excluding_lo:rate5m'  
        expression: 'sum without (device) (rate(node_network_receive_drop_total{job="node", device!="lo"}[5m]))'  
      }  
      {  
        record: 'instance:node_network_transmit_drop_excluding_lo:rate5m'  
        expression: 'sum without (device) (rate(node_network_transmit_drop_total{job="node", device!="lo"}[5m]))'  
      }  
    ]
  }
}

resource k8sPrometheusRuleGroup 'Microsoft.AlertsManagement/prometheusRuleGroups@2023-03-01' = {
  name: '${name}-${clusterName}'
  location: location
  properties:{
    interval: 'PT1M'
    enabled: true
    clusterName: clusterName
    scopes: [monitorId]
    rules: [
      {
        record: 'node_namespace_pod_container:container_cpu_usage_seconds_total:sum_irate'
        expression: 'sum by (cluster, namespace, pod, container) (irate(container_cpu_usage_seconds_total{job="cadvisor", image!=""}[5m])) * on (cluster, namespace, pod) group_left(node) topk by (cluster, namespace, pod) (1, max by(cluster, namespace, pod, node) (kube_pod_info{node!=""}))'
      }
      {
        record: 'node_namespace_pod_container:container_memory_working_set_bytes'
        expression: 'container_memory_working_set_bytes{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))'
      }
      {
        record: 'node_namespace_pod_container:container_memory_rss'
        expression: 'container_memory_rss{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))'
      }
      {
        record: 'node_namespace_pod_container:container_memory_cache'
        expression: 'container_memory_cache{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))'
      }
      {
        record: 'node_namespace_pod_container:container_memory_swap'
        expression: 'container_memory_swap{job="cadvisor", image!=""}* on (namespace, pod) group_left(node) topk by(namespace, pod) (1, max by(namespace, pod, node) (kube_pod_info{node!=""}))'
      }
      {
        record: 'cluster:namespace:pod_memory:active:kube_pod_container_resource_requests'
        expression: 'kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"} * on(namespace, pod, cluster)group_left() max by (namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))'
      }
      {
        record: 'namespace_memory:kube_pod_container_resource_requests:sum'
        expression: 'sum by (namespace, cluster) (sum by (namespace, pod, cluster) (max by (namespace, pod, container, cluster) (kube_pod_container_resource_requests{resource="memory",job="kube-state-metrics"}) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))'
      }
      {
        record: 'cluster:namespace:pod_cpu:active:kube_pod_container_resource_requests'
        expression: 'kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"} * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))'
      }
      {
        record: 'namespace_cpu:kube_pod_container_resource_requests:sum'
        expression: 'sum by (namespace, cluster) (sum by(namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_requests{resource="cpu",job="kube-state-metrics"}) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))'
      }
      {
        record: 'cluster:namespace:pod_memory:active:kube_pod_container_resource_limits'
        expression: 'kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"} * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))'
      }
      {
        record: 'namespace_memory:kube_pod_container_resource_limits:sum'
        expression: 'sum by (namespace, cluster) (sum by (namespace, pod, cluster) (max by (namespace, pod, container, cluster) (kube_pod_container_resource_limits{resource="memory",job="kube-state-metrics"}) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))'
      }
      {
        record: 'cluster:namespace:pod_cpu:active:kube_pod_container_resource_limits'
        expression: 'kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"} * on (namespace, pod, cluster)group_left() max by (namespace, pod, cluster) ((kube_pod_status_phase{phase=~"Pending|Running"} == 1))'
      }
      {
        record: 'namespace_cpu:kube_pod_container_resource_limits:sum'
        expression: 'sum by (namespace, cluster) (sum by (namespace, pod, cluster) (max by(namespace, pod, container, cluster) (kube_pod_container_resource_limits{resource="cpu",job="kube-state-metrics"}) * on(namespace, pod, cluster) group_left() max by (namespace, pod, cluster) (kube_pod_status_phase{phase=~"Pending|Running"} == 1)))'
      }
      {
        record: 'namespace_workload_pod:kube_pod_owner:relabel'
        expression: 'max by (cluster, namespace, workload, pod) (label_replace(label_replace(kube_pod_owner{job="kube-state-metrics", owner_kind="ReplicaSet"}, "replicaset", "$1", "owner_name", "(.*)") * on(replicaset, namespace) group_left(owner_name) topk by(replicaset, namespace) (1, max by (replicaset, namespace, owner_name) (kube_replicaset_owner{job="kube-state-metrics"})), "workload", "$1", "owner_name", "(.*)"))'
        labels: {
          workload_type: 'deployment'
        }
      }
      {
        record: 'namespace_workload_pod:kube_pod_owner:relabel'
        expression: 'max by (cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics", owner_kind="DaemonSet"}, "workload", "$1", "owner_name", "(.*)"))'
        labels: {
          workload_type: 'daemonset'
        }
      }
      {
        record: 'namespace_workload_pod:kube_pod_owner:relabel'
        expression: 'max by (cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics", owner_kind="StatefulSet"}, "workload", "$1", "owner_name", "(.*)"))'
        labels: {
          workload_type: 'statefulset'
        }
      }
      {
        record: 'namespace_workload_pod:kube_pod_owner:relabel'
        expression: 'max by (cluster, namespace, workload, pod) (label_replace(kube_pod_owner{job="kube-state-metrics", owner_kind="Job"}, "workload", "$1", "owner_name", "(.*)"))'
        labels: {
          workload_type: 'job'
        }
      }
      {
        record: ':node_memory_MemAvailable_bytes:sum'
        expression: 'sum(node_memory_MemAvailable_bytes{job="node"} or (node_memory_Buffers_bytes{job="node"} + node_memory_Cached_bytes{job="node"} + node_memory_MemFree_bytes{job="node"} + node_memory_Slab_bytes{job="node"})) by (cluster)'
      }
      {
        record: 'cluster:node_cpu:ratio_rate5m'
        expression: 'sum(rate(node_cpu_seconds_total{job="node",mode!="idle",mode!="iowait",mode!="steal"}[5m])) by (cluster) /count(sum(node_cpu_seconds_total{job="node"}) by (cluster, instance, cpu)) by (cluster)'
      }
    ]
  }
}

output grafanaid string = grafana.identity.principalId

