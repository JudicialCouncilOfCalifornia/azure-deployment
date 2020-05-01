#!/usr/bin/env bash

su - root

# Get environment variables to show up in SSH session
eval $(printenv | awk -F= '{print "export " "\""$1"\"""=""\""$2"\"" }' >> /etc/profile)

# start the SSH server for connecting the debugger in development
/usr/sbin/sshd -D &
