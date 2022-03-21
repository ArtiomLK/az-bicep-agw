# Azure Application Gateway

## Instructions

### Parameter Values

| Name                       | Description                                                                                  | Value                         | Examples                                                                                                              |
| -------------------------- | -------------------------------------------------------------------------------------------- | ----------------------------- | --------------------------------------------------------------------------------------------------------------------- |
| tags                       | Az Resources tags                                                                            | object                        | `{ key: value }`                                                                                                      |
| location                   | Az Resources deployment location. To get Az regions run `az account list-locations -o table` | string [default: rg location] | `eastus` \| `centralus` \| `westus` \| `westus2` \| `southcentralus`                                                  |
| agw_n                      | Application Gateway Name                                                                     | string [required]             |                                                                                                                       |
| agw_enable_zone_redundancy | Applicaton Gateway Enable Zone Redundancy Flag                                               | string [default: `false`]     | `true` \| `false`                                                                                                     |
| agw_sku                    | Application Gateway sku size                                                                 | string [required]             | `Standard_Small` \| `Standard_Medium` \| `Standard_Large` \| `WAF_Medium` \| `WAF_Large` \| `Standard_v2` \| `WAF_v2` |
| agw_tier                   | Application Gateway tier type                                                                | string [default: `false`]     | `Standard` \| `WAF` \| `Standard_v2` \| `WAF_v2`                                                                      |
| agw_capacity               | Application Gateway initial capacity                                                         | string [default: `1`]         |                                                                                                                       |
| agw_max_capacity           | Application Gateway initial capacity                                                         | string [default: `10`]        |                                                                                                                       |

### Conditional Parameter Values

### [Reference Examples][1]

## Locally test Azure Bicep Modules

```bash
# Create an Azure Resource Group
az group create \
--name 'rg-azure-bicep-application-gateway' \
--location 'eastus2' \
--tags project=bicephub env=dev

# Deploy Sample Modules
az deployment group create \
--resource-group 'rg-azure-bicep-application-gateway' \
--mode Complete \
--template-file examples/examples.bicep
```

[1]: ./examples/examples.bicep
