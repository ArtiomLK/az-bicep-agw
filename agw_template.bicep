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

module agw 'br:bicephubdev.azurecr.io/bicep/modules/agw:55880643432f21c1abdcd4ef9f506ee0b25f7616' = {
  name: take('agw-${guid(subscription().id, resourceGroup().id)}', 64)
  params: {
    location: location
    agw_backend_app_names: agw_backend_app_names
    agw_enable_zone_redundancy: agw_enable_zone_redundancy
    agw_front_end_ports: agw_front_end_ports
    agw_n: agw_n
    agw_sku: agw_sku
    agw_tier: agw_tier
    snet_agw_id: snet_agw_id
    tags: tags
  }
}
