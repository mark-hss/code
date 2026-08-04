# Azure Cloud Shell

## set subscription

first you need to find the subscription 

```
az account list \
  --query '[].{Name:name,SubscriptionId:id,State:state,Default:isDefault}' \
    --output table
```

then set the subscription

```
az account set --subscription '<SUBSCRIPTION-ID>'
```

confirm

```
az account show \
  --query '{Name:name,SubscriptionId:id,TenantId:tenantId}' \
    --output table
```
