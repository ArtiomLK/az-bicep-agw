# Azure Application Gateway

[![DEV - Deploy Azure Resource](https://github.com/ArtiomLK/azure-bicep-application-gateway/actions/workflows/dev.orchestrator.yml/badge.svg?branch=main&event=push)](https://github.com/ArtiomLK/azure-bicep-application-gateway/actions/workflows/dev.orchestrator.yml)

## Instructions

### Parameter Values

| Name                       | Description                                                                                  | Value                         | Examples                                                                                                              |
| -------------------------- | -------------------------------------------------------------------------------------------- | ----------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| tags                       | Az Resources tags                                                                            | object                        | `{ key: value }`                                                                                                      |
| location                   | Az Resources deployment location. To get Az regions run `az account list-locations -o table` | string [default: rg location] | `eastus` \| `centralus` \| `westus` \| `westus2` \| `southcentralus`                                                  |
| agw_n                      | Application Gateway Name                                                                     | string [required]             |                                                                                                                       |
| agw_enable_autoscaling     | Application Gateway Enable Autoscaling. Standard_v2 & WAF_V2 supports autoscaling            | string [default: `false`]     | `true` \| `false`                                                                                                     |
| agw_enable_zone_redundancy | Application Gateway Enable Zone Redundancy Flag                                              | string [required]             | `true` \| `false`                                                                                                     |
| agw_sku                    | Application Gateway sku size                                                                 | string [required]             | `Standard_Small` \| `Standard_Medium` \| `Standard_Large` \| `WAF_Medium` \| `WAF_Large` \| `Standard_v2` \| `WAF_v2` |
| agw_tier                   | Application Gateway tier type                                                                | string [required]             | `Standard` \| `WAF` \| `Standard_v2` \| `WAF_v2`                                                                      |
| agw_capacity               | Application Gateway initial capacity                                                         | int [default: `1`]            |                                                                                                                       |
| agw_max_capacity           | Application Gateway initial capacity                                                         | int [default: `10`]           |                                                                                                                       |
| snet_agw_id                | Application Gateway deployment subnet ID                                                     | string  [required]            |                                                                                                                       |
| snet_agw_addr              | Application Gateway deployment subnet Address space                                          | string                        | `192.168.0.24`                                                                                                        |
| agw_backend_app_names      | BackendPool App Services Names                                                               | string  [required]            | `appA,appB,appC` \| `appA` \| `appA,appB`                                                                             |
| agw_front_end_ports        | Application Gateway Front End Ports                                                          | string  [required]            | `8080,80,8081` \| `8080` \| `8080,8081`                                                                               |
| agw_pip_n                  | Application Gateway Public Ip Name                                                           | string  [required]            | `8080,80,8081` \| `8080` \| `8080,8081`                                                                               |

### Conditional Parameter Values

Application Gateway Combinations:

- `Standard`
  - SKU Tier:
    - `Standard_Small`
    - `Standard_Medium`
    - `Standard_Large`
  - agw_capacity: [1,32]
- `WAF`
  - SKU Tier:
    - `WAF_Medium`
    - `WAF_Large`
  - agw_capacity: [1,32]
- `Standard_v2`
  - SKU Tier:
    - `Standard_v2`
  - agw_enable_autoscaling available
  - agw_enable_zone_redundancy available
  - agw_capacity: [0,125]
- `WAF_v2`
  - SKU Tier:
    - `WAF_v2`
  - agw_enable_autoscaling available
  - agw_enable_zone_redundancy available
  - agw_capacity: [0,125]

### [Reference Examples][1]

## Deploy AGW Bicep Template

### Locally Deploy Azure Bicep Modules

```bash
# *Create a Sample RG if required
az group create \
--name 'rg-azure-bicep-application-gateway' \
--location 'eastus2' \
--tags project=bicephub env=dev

# Deploy AGW
az deployment group create \
--resource-group 'rg-azure-bicep-application-gateway' \
--mode Incremental \
--template-file examples/examples.bicep
```

### Deploy Azure Bicep Modules from Public Repo

```bash
# *Create a sample RG if required
az group create \
--name 'rg-azure-bicep-application-gateway' \
--location 'eastus2' \
--tags project=bicephub env=dev

# download bicep template file
curl -o agw_template.bicep https://raw.githubusercontent.com/ArtiomLK/azure-reliability-architecture/main/agw_template.bicep

# Update to latest commit by replacing main module ref tag

# download bicep parameters file
curl -o agw_parameters.json https://raw.githubusercontent.com/ArtiomLK/azure-reliability-architecture/main/agw_parameters.bicep

# Deploy AGW
az deployment group create \
--resource-group 'rg-azure-bicep-application-gateway' \
--mode Incremental \
--template-file agw_template.bicep \
--parameters @agw_parameters.json
```

### Troubleshot Guides

- [MS | If the backend health is shown as Unknown | Connection Troubleshoot][5]

## Additional Resources

- Application Gateway
- [MS | Docs | Application Gateway infrastructure configuration][4]
- Bicep IaC
- [MS | Docs | Microsoft.Network applicationGateways][2]
- [MS | Docs | Microsoft.Network publicIPAddresses][3]

[1]: ./examples/examples.bicep
[2]: https://learn.microsoft.com/en-us/azure/templates/microsoft.network/publicipaddresses
[3]: https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways
[4]: https://learn.microsoft.com/en-us/azure/application-gateway/configuration-infrastructure
[5]: https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-backend-health-troubleshooting#other-reasons
