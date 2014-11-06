#!/bin/bash

mkdir -p /config/supervisor
touch /config/supervisor/nzbdrone.log
touch /config/supervisor/nzbdrone.err

chmod 666 /config/supervisor/*

/usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

