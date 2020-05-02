#!/bin/bash

echo "Setup openrc ..." && openrc && touch /run/openrc/softlevel
# Start SSHD
rc-service sshd start

# Get environment variables to show up in SSH session
eval $(printenv | awk -F= '{print "export " "\""$1"\"""=""\""$2"\"" }' >> /etc/profile)

# make /var/solr persistent
test ! -d "/home/var/solr" && mkdir -p /home/var && mv /var/solr /home/var/solr && ln -s /home/var/solr /var/solr
test -d "/home/var/solr" && rm -rf /var/solr && ln -s /home/var/solr /var/solr
test ! -d "/home/LogFiles/solr/logs" && mkdir -p /home/LogFiles/solr && mv /var/solr/logs /home/LogFiles/solr/. && ln -s /home/LogFiles/solr/logs /var/solr/logs
test -d "/home/LogFiles/solr/logs" && rm -rf /var/solr/logs && ln -s /home/LogFiles/solr/logs /var/solr/logs