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
// Sample App Service Plan parameters
param plan_enable_zone_redundancy bool = false

// ------------------------------------------------------------------------------------------------
// REPLACE
// '../main.bicep' by the ref with your version, for example:
// 'br:bicephubdev.azurecr.io/bicep/modules/plan:v1'
// ------------------------------------------------------------------------------------------------

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

resource vnetApp 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'vnet-azure-bicep-app-service'
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
  name: 'plan-azure-bicep-app-service-test'
  location: location
  sku: {
    name: 'P1V3'
    tier: 'PremiumV3'
    capacity: plan_enable_zone_redundancy ? 3 : 1
  }
  properties: {
    zoneRedundant: plan_enable_zone_redundancy
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
module DeployAgwOneAppStandardSmall '../main.bicep' = {
  name: 'DeployAgwOneAppStandardSmall'
  params: {
    location: location
    agw_backend_app_names: appN.name
    agw_sku: 'Standard_Small'
    agw_tier: 'Standard'
    snet_agw_id: vnetApp.properties.subnets[0].id
    agw_front_end_ports: '80'
    agw_n: 'agw-DeployAgwOneAppStandardSmall'
  }
}

module DeployAgwOneAppStandardMedium '../main.bicep' = {
  name: 'DeployAgwOneAppStandardMedium'
  params: {
    location: location
    agw_backend_app_names: appN.name
    agw_sku: 'Standard_Medium'
    agw_tier: 'Standard'
    snet_agw_id: vnetApp.properties.subnets[1].id
    agw_front_end_ports: '80'
    agw_n: 'agw-DeployAgwOneAppStandardMedium'
  }
}

module DeployAgwOneAppStandardLarge '../main.bicep' = {
  name: 'DeployAgwOneAppStandardLarge'
  params: {
    location: location
    agw_backend_app_names: appN.name
    agw_sku: 'Standard_Large'
    agw_tier: 'Standard'
    snet_agw_id: vnetApp.properties.subnets[2].id
    agw_front_end_ports: '80'
    agw_n: 'agw-DeployAgwOneAppStandardLarge'
  }
}

module DeployAgwOneAppWAFMedium '../main.bicep' = {
  name: 'DeployAgwOneAppWAFMedium'
  params: {
    location: location
    agw_backend_app_names: appN.name
    agw_sku: 'WAF_Medium'
    agw_tier: 'WAF'
    snet_agw_id: vnetApp.properties.subnets[3].id
    agw_front_end_ports: '80'
    agw_n: 'agw-DeployAgwOneAppWAFMedium'
  }
}

module DeployAgwOneAppWAFLarge '../main.bicep' = {
  name: 'DeployAgwOneAppWAFLarge'
  params: {
    location: location
    agw_backend_app_names: appN.name
    agw_sku: 'WAF_Large'
    agw_tier: 'WAF'
    snet_agw_id: vnetApp.properties.subnets[4].id
    agw_front_end_ports: '80'
    agw_n: 'agw-DeployAgwOneAppWAFLarge'
  }
}

module DeployAgwOneAppStandardV2 '../main.bicep' = {
  name: 'DeployAgwOneAppStandardV2'
  params: {
    location: location
    agw_backend_app_names: appA.name
    agw_sku: 'Standard_v2'
    agw_tier: 'Standard_v2'
    snet_agw_id: vnetApp.properties.subnets[5].id
    agw_front_end_ports: '80'
    agw_n: 'agw-DeployAgwOneAppStandardV2'
  }
}

module DeployAgwOneAppStandardWAFV2 '../main.bicep' = {
  name: 'DeployAgwOneAppStandardWAFV2'
  params: {
    location: location
    agw_backend_app_names: appA.name
    agw_sku: 'WAF_v2'
    agw_tier: 'WAF_v2'
    snet_agw_id: vnetApp.properties.subnets[6].id
    agw_front_end_ports: '80'
    agw_n: 'agw-DeployAgwOneAppStandardWAFV2'
  }
}

module DeployAgwMultiAppStandardV2 '../main.bicep' = {
  name: 'DeployAgwMultiAppStandardV2'
  params: {
    location: location
    agw_backend_app_names: '${appA.name},${appB.name},${appC.name}'
    agw_sku: 'Standard_v2'
    agw_tier: 'Standard_v2'
    snet_agw_id: vnetApp.properties.subnets[7].id
    agw_front_end_ports: '80,8080,8081'
    agw_n: 'agw-DeployAgwMultiAppStandardV2'
  }
}

module DeployAgwMultiAppStandardV2CustomScaling '../main.bicep' = {
  name: 'DeployAgwMultiAppStandardV2CustomScaling'
  params: {
    agw_capacity:2
    agw_max_capacity: 32
    location: location
    agw_backend_app_names: '${appA.name},${appB.name},${appC.name}'
    agw_sku: 'Standard_v2'
    agw_tier: 'Standard_v2'
    snet_agw_id: vnetApp.properties.subnets[8].id
    agw_front_end_ports: '80,8080,8081'
    agw_n: 'agw-DeployAgwMultiAppStandardV2CustomScaling'
  }
}

