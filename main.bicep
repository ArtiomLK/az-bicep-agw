// ------------------------------------------------------------------------------------------------
// Deployment parameters
// ------------------------------------------------------------------------------------------------
@description('Az Resources tags')
param tags object = {}
@description('Az Resources deployment location')
param location string

// ------------------------------------------------------------------------------------------------
// AGW Configuration parameters
// ------------------------------------------------------------------------------------------------
@description('Application Gateway Public Ip Name')
param agw_pip_n string ='pip-${agw_n}'

@description('Application Gateway Name')
param agw_n string

@description('Applicaton Gateway Enable Zone Redundancy Flag')
param agw_enable_zone_redundancy bool = true

@description('Application Gateway sku size')
@allowed([
  'Standard_Small'
  'Standard_Medium'
  'Standard_Large'
  'WAF_Medium'
  'WAF_Large'
  'Standard_v2'
  'WAF_v2'
])
param agw_sku string

@description('Application Gateway tier type')
@allowed([
  'Standard'
  'WAF'
  'Standard_v2'
  'WAF_v2'
])
param agw_tier string
var agw_v2 = agw_tier == 'Standard_v2' || agw_tier ==  'WAF_v2'

@description('Application Gateway Enable Autoscaling. Standard_v2 & WAF_V2 supports autoscaling')
param agw_enable_autoscaling bool = false

@description('Application Gateway initial capacity')
@minValue(0)
@maxValue(124)
param agw_capacity int = 1
var agw_min_capacity = (!agw_v2 &&  agw_capacity == 0) ? 1 : agw_capacity

@description('Application Gateway Maximum capacity')
@minValue(0)
@maxValue(125)
param agw_max_capacity int = 10

@description('Application Gateway deployment subnet ID')
param snet_agw_id string

// ------------------------------------------------------------------------------------------------
// AGW Back End Rule Configuration
// ------------------------------------------------------------------------------------------------
@description('Backend App Services Names. E.G. appA,appB,appC | appA | appA,appB')
param agw_backend_app_names string
var app_names_parsed = split(agw_backend_app_names, ',')

@description('Application Gatweay Front End Ports. E.G. 8080,80,8081 | 8080 | 8080,8081')
param agw_front_end_ports string
var agw_front_end_ports_parsed = split(agw_front_end_ports, ',')

var agw_front_end_port_names = [for app_n in app_names_parsed: take('${app_n}-front-end-port', 80)]
var agw_http_listener_names = [for app_n in app_names_parsed: take('${app_n}-http-lister', 80)]
var agw_backend_addr_pool_names = [for app_n in app_names_parsed: take('${app_n}-backend-addr-pool', 80)]
var agw_backend_addr_pool_fqdn = [for app_n in app_names_parsed: take('${app_n}.azurewebsites.net', 80)]
var agw_backend_http_setting_names = [for app_n in app_names_parsed: take('${app_n}-backend-http-settings', 80)]
var agw_health_probe_names = [for app_n in app_names_parsed: take('${app_n}-health-probe', 80)]
var agw_rules = [for app_n in app_names_parsed: take('${app_n}-rule', 80)]

var agw_snet_ip_config_n = 'agw-snet-ip-config'
var agw_frontend_ip_config_n = 'agw-frontend-ip-config'

// ------------------------------------------------------------------------------------------------
// Deploy PIP
// ------------------------------------------------------------------------------------------------
resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2021-03-01' = {
  name: agw_pip_n
  tags: tags
  location: location
  sku: {
    name: agw_v2 ? 'Standard' : 'Basic'
  }
  properties: {
    publicIPAllocationMethod: agw_v2 ? 'Static' : 'Dynamic'
  }
  zones: agw_enable_zone_redundancy && agw_v2 ? [
    '1'
    '2'
    '3'
  ] : []
}

// ------------------------------------------------------------------------------------------------
// Deploy AGW
// ------------------------------------------------------------------------------------------------
resource applicationGateway 'Microsoft.Network/applicationGateways@2021-05-01' = {
  name: agw_n
  tags: tags
  location: location
  zones: agw_enable_zone_redundancy && agw_v2 ? [
    '1'
    '2'
    '3'
  ] : []
  properties: {
    sku: {
      name: agw_sku
      tier: agw_tier
      capacity: agw_enable_autoscaling ? null : agw_min_capacity
    }
    autoscaleConfiguration: agw_enable_autoscaling ? {
      minCapacity: agw_min_capacity
      maxCapacity: agw_max_capacity
    } : null
    gatewayIPConfigurations: [
      {
        name: agw_snet_ip_config_n
        properties: {
          subnet: {
            id: snet_agw_id
          }
        }
      }
    ]

    frontendIPConfigurations: [
      {
        name: agw_frontend_ip_config_n
        properties: {
          publicIPAddress: {
            id: publicIpAddress.id
          }
        }
      }
    ]

    frontendPorts: [for i in range(0, length(app_names_parsed)): {
      name: agw_front_end_port_names[i]
      properties: {
        port: int(agw_front_end_ports_parsed[i])
      }
    }]

    backendAddressPools: [for i in range(0, length(app_names_parsed)): {
      name: agw_backend_addr_pool_names[i]
      properties: {
        backendAddresses: [
          {
            fqdn: agw_backend_addr_pool_fqdn[i]
          }
        ]
      }
    }]

    backendHttpSettingsCollection: [for i in range(0, length(app_names_parsed)): {
      name: agw_backend_http_setting_names[i]
      properties: {
        port: 80
        protocol: 'Http'
        cookieBasedAffinity: 'Disabled'
        pickHostNameFromBackendAddress: true
        probeEnabled: true
        probe: {
          id: resourceId('Microsoft.Network/applicationGateways/probes', agw_n, agw_health_probe_names[i])
        }
      }
    }]

    httpListeners: [for i in range(0, length(app_names_parsed)): {
      name: agw_http_listener_names[i]
      properties: {
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', agw_n, agw_frontend_ip_config_n)
        }
        frontendPort: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', agw_n, agw_front_end_port_names[i])
        }
        protocol: 'Http'
        sslCertificate: null
      }
    }]

    requestRoutingRules: [for i in range(0, length(app_names_parsed)): {
      name: agw_rules[i]
      properties: {
        ruleType: 'Basic'
        httpListener: {
          id: resourceId('Microsoft.Network/applicationGateways/httpListeners', agw_n, agw_http_listener_names[i])
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', agw_n, agw_backend_addr_pool_names[i])
        }
        backendHttpSettings: {
          id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', agw_n, agw_backend_http_setting_names[i])
        }
      }
    }]

    probes: [for i in range(0, length(app_names_parsed)): {
      name: agw_health_probe_names[i]
      properties: {
        protocol: 'Http'
        pickHostNameFromBackendHttpSettings: true
        path: '/'
        timeout: 20
        interval: 30
        unhealthyThreshold: 3
      }
    }]
  }
}

output id string = applicationGateway.id
output pip_ip string = publicIpAddress.properties.ipAddress
