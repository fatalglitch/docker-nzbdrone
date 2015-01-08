#docker Sonarr

## Description:

This docker image is for running Sonarr - (https://sonarr.tv/), specifically within an unRAID environment.
The resulting container uses supervisor in order to stop and start Sonarr after an upgrade has occur.

![Alt text](https://pbs.twimg.com/profile_images/434619753638805504/k6UqTgpb_400x400.png "")

## How to use this image:

### start a Sonarr instance:

```
docker run -d --net=host -v /*your_config_location*:/config  -v /*your_mount_location*:/mnt -e TZ=America/Edmonton --name=Sonarr hurricane/docker-nzbdrone
```

### Updating

To update successfully, you must configure Sonarr to use the update script in /scripts/sonarr-update.sh. This is configured under Settings > (show advanced) > General > Updates > change Mechanism to Script.

## Volumes:

#### `/config`
Configuration files and state of NzbDrone. (i.e. /opt/appdata/NzbDrone)

#### `/mnt`
Location of mount folders, or root folder of unRAID share mount points. (i.e. /opt/downloads or /media/Tower or /mnt)

## Environment Variables

The Sonarr image uses one optional enviromnet variable.

####`TZ`
This environment variable is used to set the [TimeZone] of the container.

[TimeZone]: http://en.wikipedia.org/wiki/List_of_tz_database_time_zones

## Build from docker file (Info only, not required.):

```
git clone https://github.com/HurricaneHernandez/docker-nzbdrone.git 
cd docker-nzbdrone
docker build -t sonarr . 
```
