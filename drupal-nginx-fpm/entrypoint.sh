#!/bin/bash

# set -e

php -v

echo "Setup openrc ..." && openrc && touch /run/openrc/softlevel

# setup Drupal
echo "DEPLOYING SITE..."

WWW_ROOT=$DRUPAL_PRJ/$WWW_SUBDIR
test ! -d "$DRUPAL_PRJ" && echo "INFO: $DRUPAL_PRJ not found. Creating..." && mkdir -p "$DRUPAL_PRJ"
cd $DRUPAL_PRJ
cp -R $DRUPAL_BUILD/* $DRUPAL_PRJ/.
composer install
test ! -d $WWW_ROOT/themes/custom/jcc_base/node_modules && scripts/theme.sh -a

test ! -d "$DRUPAL_PRJ/web/sites/default/files" && mkdir -p "$DRUPAL_PRJ/web/sites/default/files"
chmod a+w "$DRUPAL_PRJ/web/sites/default"
test -d "$DRUPAL_PRJ/web/sites/default/settings.local.php" && chmod a+w "$DRUPAL_PRJ/web/sites/default/settings.local.php" && rm "$DRUPAL_PRJ/web/sites/default/settings.local.php"
cp "$DRUPAL_SOURCE/settings.local.php" "$DRUPAL_PRJ/web/sites/default/settings.local.php"
chmod a+w "$DRUPAL_PRJ/web/sites/default/files"
chmod a-w "$DRUPAL_PRJ/web/sites/default/settings.php"

# Persist drupal/sites
test ! -d "$DRUPAL_STORAGE" && mkdir -p "$DRUPAL_STORAGE"
test ! -d "$DRUPAL_STORAGE/sites/default/files" && mv $DRUPAL_PRJ/web/sites/default/files $DRUPAL_STORAGE/files
ln -s $DRUPAL_STORAGE/files $DRUPAL_PRJ/web/sites/default/files

# Create log folders
test ! -d "$SUPERVISOR_LOG_DIR" && echo "INFO: $SUPERVISOR_LOG_DIR not found. creating ..." && mkdir -p "$SUPERVISOR_LOG_DIR"
test ! -d "$VARNISH_LOG_DIR" && echo "INFO: Log folder for varnish found. creating..." && mkdir -p "$VARNISH_LOG_DIR"
test ! -d "$NGINX_LOG_DIR" && echo "INFO: Log folder for nginx/php not found. creating..." && mkdir -p "$NGINX_LOG_DIR"
test ! -e /home/50x.html && echo "INFO: 50x file not found. createing..." && cp /usr/share/nginx/html/50x.html /home/50x.html
# Backup default nginx setting, use customer's nginx setting
test -d "/home/etc/nginx" && mv /etc/nginx /etc/nginx-bak && ln -s /home/etc/nginx /etc/nginx
test ! -d "/home/etc/nginx" && mkdir -p /home/etc && mv /etc/nginx /home/etc/nginx && ln -s /home/etc/nginx /etc/nginx
# Backup default varnish setting, use customer's nginx setting
test -d "/home/etc/varnish" && mv /etc/varnish /etc/varnish-bak && ln -s /home/etc/varnish /etc/varnish
test ! -d "/home/etc/varnish" && mkdir -p /home/etc && mv /etc/varnish /home/etc/varnish && ln -s /home/etc/varnish /etc/varnish

#echo "Starting Varnishd ..."
if [ "$ENABLE_VARNISH" == "true" ];then
  /usr/sbin/varnishd -a :80 -f /etc/varnish/default.vcl
  sed -i 's|listen 80;|listen 8080;|g' /home/etc/nginx/nginx.conf
  sed -i 's|listen [::]:80;|listen [::]:8080;|g' /home/etc/nginx/nginx.conf
fi

# Set WWW root
sed -i "s|WWW_ROOT|$WWW_ROOT|g" /home/etc/nginx/nginx.conf

if [ "$HTML_ONLY" == "true" ];then
  sed -i 's|try_files $uri /index.php?$query_string;|try_files $uri /index.html;|g' /home/etc/nginx/nginx.conf
fi

echo "INFO: creating /run/php/php-fpm.sock ..."
test -e /run/php/php7.0-fpm.sock && rm -f /run/php/php7.0-fpm.sock
mkdir -p /run/php && touch /run/php/php7.0-fpm.sock && chown nginx:nginx /run/php/php7.0-fpm.sock && chmod 777 /run/php/php7.0-fpm.sock

sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config

# Get environment variables to show up in SSH session
eval $(printenv | awk -F= '{print "export " "\""$1"\"""=""\""$2"\"" }' >> /etc/profile)

echo "Starting SSH ..."
echo "Starting php-fpm ..."
echo "Starting Nginx ..."

cd /usr/bin/
supervisord -c /etc/supervisord.conf
