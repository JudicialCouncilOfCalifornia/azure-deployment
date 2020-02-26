# drupal-nginx-fpm Docker
This is a Drupal Docker image which can run on both 
 - [Azure Web App on Linux](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-intro)
 - [Drupal on Linux Web App With MySQL](https://ms.portal.azure.com/#create/Drupal.Drupalonlinux )

# Components
This docker image currently contains the following components:
1. Drupal
2. nginx (1.16.1)
3. PHP-FPM (7.4.2)
4. Drush
5. Composer (1.8.5)

## How to Deploy to Azure 
1. Create a Web App for Containers, set Docker container as ```judicialcouncil/drupal-nginx-fpm:1.0``` 
2. Add the following settings variables:

Name | Default Value
---- | -------------
GIT_REPO | https://github.com/JudicialCouncilOfCalifornia/trialcourt
GIT_BRANCH | master
WEBSITES_CONTAINER_START_TIME_LIMIT | 600
WEBSITES_ENABLE_APP_SERVICE_STORAGE | true
DATABASE_HOST | 
DATABASE_NAME |
DATABASE_USER |
DATABASE_PASSWORD |
RESET_INSTANCE | false

3. Browse your site and wait almost 5 mins.
4. Complete Drupal install.

# How to turn on Xdebug
1. By default Xdebug is turned off as turning it on impacts performance.
2. Connect by SSH.
3. Go to ```/usr/local/etc/php/conf.d```,  Update ```xdebug.ini``` as wish, don't modify the path of below line.
```zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20180731/xdebug.so```
4. Save ```xdebug.ini```, Restart php-fpm by below cmd:
```
# Kill master process of php-fpm
killall -9 php-fpm
# php-fpm will be started by supervisor.
```

## How to update config files of nginx
1. Go to "/etc/nginx", update config files as your wish. 
2. Reload by below cmd: 
```
/usr/sbin/nginx -s reload
```
## How to update config files of varnish
1. Go to "/etc/varnish", update config files. 
