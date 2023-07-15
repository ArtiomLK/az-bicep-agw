targetScope = 'resourceGroup'
// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
// Sample tags parameters
var tags = {
  project: 'bicephub'
  env: 'dev'
}

param location string = 'eastus'

// ------------------------------------------------------------------------------------------------
// Applciation Gateway Networking Configurations Examples
// ------------------------------------------------------------------------------------------------
var vnet_addr = '192.160.0.0/20'
var snet_count = 16
var subnets = [ for i in range(0, snet_count) : {
    name: 'snet-${i}-agw-azure-bicep'
    subnetPrefix: '192.160.${i}.0/24'
    privateEndpointNetworkPolicies: 'Enabled'
    delegations: []
  }]

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'vnet-agw'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnet_addr
      ]
    }
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.subnetPrefix
        delegations: subnet.delegations
        privateEndpointNetworkPolicies: subnet.privateEndpointNetworkPolicies
      }
    }]
  }
}

// Create a Windows Sample App Service Plan
resource appServicePlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  tags: tags
  name: 'plan-test'
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
  }
}

resource appA 'Microsoft.Web/sites@2018-11-01' = {
  name: take('appA-${guid(subscription().id, resourceGroup().id, tags.env)}', 60)
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource appB 'Microsoft.Web/sites@2018-11-01' = {
  name: take('appB-${guid(subscription().id, resourceGroup().id, tags.env)}', 60)
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource appC 'Microsoft.Web/sites@2018-11-01' = {
  name: take('appC-${guid(subscription().id, resourceGroup().id, tags.env)}', 60)
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource appN 'Microsoft.Web/sites@2018-11-01' = {
  name: take('appN-${guid(subscription().id, resourceGroup().id, tags.env)}', 60)
  location: location
  tags: tags
  properties: {
    serverFarmId: appServicePlan.id
  }
}

// ------------------------------------------------------------------------------------------------
// Applciation Gateway Deployment Examples
// ------------------------------------------------------------------------------------------------
module DeployAgwOneAppStandardV2 '../main.bicep' = {
  name: 'DeployAgwOneAppStandardV2'
  params: {
    location: location
    agw_backend_app_names: appA.name
    agw_sku: 'Standard_v2'
    agw_tier: 'Standard_v2'
    snet_agw_id: vnet.properties.subnets[5].id
    agw_front_end_ports: '80'
    agw_n: 'agw-DeployAgwOneAppStandardV2'
    agw_enable_zone_redundancy: false
  }
}

module DeployAgwOneAppStandardWAFV2 '../main.bicep' = {
  name: 'DeployAgwOneAppStandardWAFV2'
  params: {
    location: location
    agw_backend_app_names: appA.name
    agw_sku: 'WAF_v2'
    agw_tier: 'WAF_v2'
    snet_agw_id: vnet.properties.subnets[6].id
    agw_front_end_ports: '80'
    agw_n: 'agw-DeployAgwOneAppStandardWAFV2'
    agw_enable_zone_redundancy: true
  }
}

module DeployAgwMultiAppStandardV2 '../main.bicep' = {
  name: 'DeployAgwMultiAppStandardV2'
  params: {
    location: location
    agw_backend_app_names: '${appA.name},${appB.name},${appC.name}'
    agw_sku: 'Standard_v2'
    agw_tier: 'Standard_v2'
    snet_agw_id: vnet.properties.subnets[7].id
    agw_front_end_ports: '80,8080,8081'
    agw_n: 'agw-DeployAgwMultiAppStandardV2'
    agw_enable_zone_redundancy: true
  }
}

module DeployAgwMultiAppStandardV2CustomScaling '../main.bicep' = {
  name: 'DeployAgwMultiAppStandardV2CustomScaling'
  params: {
    agw_enable_autoscaling: true
    agw_capacity:2
    agw_max_capacity: 32
    location: location
    agw_backend_app_names: '${appA.name},${appB.name},${appC.name}'
    agw_sku: 'Standard_v2'
    agw_tier: 'Standard_v2'
    snet_agw_id: vnet.properties.subnets[8].id
    agw_front_end_ports: '80,8080,8081'
    agw_n: 'agw-DeployAgwMultiAppStandardV2CustomScaling'
    agw_enable_zone_redundancy: true
  }
}

module DeployAgwMultiAppStandardV2CustomScalingPrivIp '../main.bicep' = {
  name: 'DeployAgwMultiAppStandardV2CustomScalingPrivIp'
  params: {
    agw_enable_autoscaling: true
    agw_capacity:0
    agw_max_capacity: 125
    location: location
    agw_backend_app_names: '${appA.name},${appB.name},${appC.name}'
    agw_sku: 'Standard_v2'
    agw_tier: 'Standard_v2'
    snet_agw_id: vnet.properties.subnets[9].id
    agw_priv_ip_addr: '192.160.9.4'
    agw_front_end_ports: '80,8080,8081'
    agw_n: 'agw-DeployAgwMultiAppStandardV2CustomScalingPrivIp'
    agw_enable_zone_redundancy: true
  }
}

