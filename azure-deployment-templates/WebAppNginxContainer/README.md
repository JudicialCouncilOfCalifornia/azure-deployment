# Azure template deployment

This template creates a server and deploys a container.

```
az deployment group create \
  --name DeployLocalTemplate \
  --resource-group "WebCMS-PROD-Drupal" \
  --template-file template.json \
  --parameters parameters.json \
  --verbose
```