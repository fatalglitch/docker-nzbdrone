#!/bin/bash
 
# 52 /tmp/nzbdrone_update /opt/NzbDrone/NzbDrone.exe
 
echo "updating sonarr"
rm -Rfv /opt/NzbDrone/*
mv /tmp/nzbdrone_update/NzbDrone/* /opt/NzbDrone/
 
echo "Using supervisorctl to restart sonarr"
supervisorctl stop nzbdrone
sleep 5
supervisorctl start nzbdrone