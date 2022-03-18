# Azure Application Gateway

## Instructions

### Parameter Values

| Name                        | Description                                                                                  | Value                         | Examples                                                             |
| --------------------------- | -------------------------------------------------------------------------------------------- | ----------------------------- | -------------------------------------------------------------------- |
| tags                        | Az Resources tags                                                                            | object                        | `{ key: value }`                                                     |
| location                    | Az Resources deployment location. To get Az regions run `az account list-locations -o table` | string [default: rg location] | `eastus` \| `centralus` \| `westus` \| `westus2` \| `southcentralus` |
| plan_n                      | App Service Plan Name                                                                        | string [required]             |                                                                      |
| plan_sku_code               | App Service Plan Size                                                                        | string [default: `F1`]        | `F1` \| `S2` \| `P1V2` \| `P3V2` \| `P3V3`                           |
| plan_sku_tier               | App Service Plan SKU Tier                                                                    | string [default: `Free`]      | `Free` \| `Basic` \| `Standard` \| `PremiumV2` \| `PremiumV3`        |
| plan_os_kind                | App Service Plan OS kind                                                                     | string [default: `windows`]   | `windows` \| `'linux'`                                               |
| plan_enable_zone_redundancy | Enable App Service Plan High Availability Zone Redundancy                                    | string                        |                                                                      |

### Conditional Parameter Values

#### App Service Plan Combinations

Only PremiumV2 and PremiumV3 allow Hight Availability Zone Redundancy

- App Service Plan **Free**:
  - `Free`
    - `F1`
- App Service Plan **Basic**:
  - `Standard`
    - `S1`
    - `S2`
    - `S3`
- App Service Plan **PremiumV2** allows Hight Availability Zone Redundancy:
  - `PremiumV2`
    - `P1V2`
    - `P2V2`
    - `P3V2`
- App Service Plan **PremiumV3** allows Hight Availability Zone Redundancy:
  - `PremiumV3`
    - `P1V3`
    - `P2V3`
    - `P3V3`

### [Reference Examples][1]

## Locally test Azure Bicep Modules

```bash
# Create an Azure Resource Group
az group create \
--name 'rg-azure-bicep-app-service-plan' \
--location 'eastus2' \
--tags project=bicephub env=dev

# Deploy Sample Modules
az deployment group create \
--resource-group 'rg-azure-bicep-app-service-plan' \
--mode Complete \
--template-file examples/examples.bicep
```

[1]: ./examples/examples.bicep
