# Azure template deployment

This deployment template deploys:
- App Service Plan
- App Service
- Azure Database for MariaDB Server
- Azure Cache for Redis

```
az deployment group create \
  --name DeployLocalTemplate \
  --resource-group "WebCMS-PROD-Drupal" \
  --template-file template.json \
  --parameters parameters.json \
  --verbose
```