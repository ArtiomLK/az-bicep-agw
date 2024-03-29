targetScope = 'resourceGroup'

@description('Resource tags')
param tags object = {}
param location string

param agw_n string
param agw_backend_app_names string
param agw_enable_zone_redundancy bool
param agw_front_end_ports string
param agw_sku string
param agw_tier string
param snet_agw_id string
param agw_priv_ip_addr string = ''

module agw 'br:bicephubdev.azurecr.io/bicep/modules/agw:cf59d3f7f1e606880a6830202af12a21fefa0a08' = {
  name: take('${agw_n}-${guid(subscription().id, resourceGroup().id)}', 64)
  params: {
    location: location
    agw_backend_app_names: agw_backend_app_names
    agw_enable_zone_redundancy: agw_enable_zone_redundancy
    agw_front_end_ports: agw_front_end_ports
    agw_n: agw_n
    agw_sku: agw_sku
    agw_tier: agw_tier
    snet_agw_id: snet_agw_id
    agw_priv_ip_addr: agw_priv_ip_addr
    tags: tags
  }
}
