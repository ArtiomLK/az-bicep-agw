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
var subnets = [
  {
    name: 'snet-agw-azure-bicep'
    subnetPrefix: '192.160.0.0/24'
    privateEndpointNetworkPolicies: 'Enabled'
    delegations: []
  }
]

resource vnetApp 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'vnet-azure-bicep-app-service'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '192.160.0.0/23'
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

// ------------------------------------------------------------------------------------------------
// Applciation Gateway Deployment Examples
// ------------------------------------------------------------------------------------------------
module DeployAgwOneApp '../main.bicep' = {
  name: 'DeployAgwOneApp'
  params: {
    location: location
    agw_backend_app_names: appA.name
    agw_sku: 'Standard_v2'
    agw_tier: 'Standard_v2'
    snet_agw_id: vnetApp.properties.subnets[0].id
    agw_front_end_ports: '8080'
    agw_n: 'agw-DeployAgwOneApp'
  }
}

module DeployAgwMultiApp '../main.bicep' = {
  name: 'DeployAgwMultiApp'
  params: {
    location: location
    agw_backend_app_names: '${appA.name},${appB.name},${appC.name}'
    agw_sku: 'Standard_v2'
    agw_tier: 'Standard_v2'
    snet_agw_id: vnetApp.properties.subnets[0].id
    agw_front_end_ports: '80,8080,8081'
    agw_n: 'agw-DeployAgwMultiApp'
  }
}
