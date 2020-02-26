# JCC Drupal Docker Image for Azure

Contains:
* alpine 3.11
* nginx 1.16.1
* php 7.3.15
* php-fpm

## Deploying to Azure

1. Launch an Azure Web App Service
2. Select "Docker Container" under Instance Details
3. Set "Image Source" to "Docker Hub"
4. Set "Image and Tag" to "judicialcouncil/drupal-nginx-fpm:1.1"
5. Create
6. After the resource is deployed, go to "Configuration"
7. Click on "Advanced Edit" and paste this environment variables:
    ```
    [
      {
        "name": "DATABASE_HOST",
        "value": "",
        "slotSetting": false
      },
      {
        "name": "DATABASE_NAME",
        "value": "",
        "slotSetting": false
      },
      {
        "name": "DATABASE_PASSWORD",
        "value": "",
        "slotSetting": false
      },
      {
        "name": "DATABASE_USER",
        "value": "",
        "slotSetting": false
      },
      {
        "name": "DOCKER_REGISTRY_SERVER_URL",
        "value": "https://index.docker.io",
        "slotSetting": false
      },
      {
        "name": "GIT_BRANCH",
        "value": "stage",
        "slotSetting": false
      },
      {
        "name": "GIT_REPO",
        "value": "https://github.com/JudicialCouncilOfCalifornia/trialcourt",
        "slotSetting": false
      },
      {
        "name": "RESET_INSTANCE",
        "value": "false",
        "slotSetting": false
      },
      {
        "name": "WEBSITE_HTTPLOGGING_RETENTION_DAYS",
        "value": "7",
        "slotSetting": false
      },
      {
        "name": "WEBSITES_CONTAINER_START_TIME_LIMIT",
        "value": "1800",
        "slotSetting": false
      },
      {
        "name": "WEBSITES_ENABLE_APP_SERVICE_STORAGE",
        "value": "true",
        "slotSetting": false
      }
    ]
    ```
8. Fill in the appropriate values above and save.
9. Wait ~15 minutes for Azure App to complete deployment.  There is a delay with LogStream and the state of the container in the service.  It is hard to gauge whether a server error is valid or not.

## Inside the container

1. The container will clone the given GIT_REPO if source is not found or RESET_INSTANCE is true.
2. Otherwise, it reuses existing source code.
3. It will move the Drupal files folder into a persistent storage, and symlink to it from the source code.