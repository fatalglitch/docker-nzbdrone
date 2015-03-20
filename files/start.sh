#!/bin/bash

echo "Running start script."

mkdir -p /config/supervisor
touch /config/supervisor/nzbdrone.log
touch /config/supervisor/nzbdrone.err

chmod 666 /config/supervisor/*

echo "Setting up Sonarr."
run-parts -v  --report /etc/setup.d

chown -R nobody:users /config

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

