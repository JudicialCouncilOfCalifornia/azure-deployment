#!/bin/bash

# set -e

php -v

fresh_drupal_installation(){
  while test -d "$DRUPAL_PRJ"
    do
      test ! -d "$DRUPAL_BACKUP" && mkdir -p "$DRUPAL_BACKUP"
      echo "INFO: $DRUPAL_PRJ exists. Clean it ..."
      mv $DRUPAL_PRJ $DRUPAL_BACKUP/drupal_source_$(date +%s)
    done

  test ! -d "$DRUPAL_PRJ" && echo "INFO: $DRUPAL_PRJ not found. Creating..." && mkdir -p "$DRUPAL_PRJ"

  cd $DRUPAL_PRJ
  GIT_REPO=${GIT_REPO:-https://github.com/JudicialCouncilOfCalifornia/trialcourt}
  GIT_BRANCH=${GIT_BRANCH:-develop}
  echo "INFO: ++++++++++++++++++++++++++++++++++++++++++++++++++:"
  echo "REPO: "$GIT_REPO
  echo "BRANCH: "$GIT_BRANCH
  echo "INFO: ++++++++++++++++++++++++++++++++++++++++++++++++++:"

  echo "INFO: Clone from "$GIT_REPO
  git clone $GIT_REPO $DRUPAL_PRJ	&& cd $DRUPAL_PRJ
  if [ "$GIT_BRANCH" != "master" ];then
    echo "INFO: Checkout to "$GIT_BRANCH
    git fetch origin
    git branch --track $GIT_BRANCH origin/$GIT_BRANCH && git checkout $GIT_BRANCH
  fi

  composer install
}

# Setup Drupal
setup_drupal(){
  if [ ! -d "$DRUPAL_PRJ" ] || [ "$RESET_INSTANCE" == "true" ];then
    # New installation or explicit reset
    echo "FRESH DRUPAL INSTALLATION..."
    fresh_drupal_installation
  fi

  echo "DEPLOYING SITE SETTINGS..."
  chmod a+w "$DRUPAL_PRJ/web/sites/default"
  test -d "$DRUPAL_PRJ/web/sites/default/settings.local.php" && chmod a+w "$DRUPAL_PRJ/web/sites/default/settings.local.php" && rm "$DRUPAL_PRJ/web/sites/default/settings.local.php"
  cp "$DRUPAL_SOURCE/settings.local.php" "$DRUPAL_PRJ/web/sites/default/settings.local.php"
  test ! -d "$DRUPAL_PRJ/web/sites/default/files" && mkdir -p "$DRUPAL_PRJ/web/sites/default/files"
  chmod a+w "$DRUPAL_PRJ/web/sites/default/files"
  chmod a+w "$DRUPAL_PRJ/web/sites/default/settings.php"
  while test -d "$DRUPAL_HOME"
  do
      echo "INFO: $DRUPAL_HOME exists.  Clean it ..."
      chmod 777 -R $DRUPAL_HOME
      rm -Rf $DRUPAL_HOME
  done
  ln -s $DRUPAL_PRJ/web  $DRUPAL_HOME
}

if [ ! $WEBSITES_ENABLE_APP_SERVICE_STORAGE ]; then 
    echo "INFO: NOT in Azure, chown for "$DRUPAL_HOME 
    chown -R nginx:nginx $DRUPAL_HOME
fi

echo "Setup openrc ..." && openrc && touch /run/openrc/softlevel

# setup Drupal
setup_drupal

if [ ! $WEBSITES_ENABLE_APP_SERVICE_STORAGE ]; then
    echo "INFO: NOT in Azure, chown for "$DRUPAL_PRJ  
    chown -R nginx:nginx $DRUPAL_PRJ

    echo "NOT in AZURE, Start crond, log rotate..."
    crond
fi

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

echo "Starting Varnishd ..."
/usr/sbin/varnishd -a :80 -f /etc/varnish/default.vcl

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
