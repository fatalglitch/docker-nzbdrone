#docker NzbDrone

## Description:

This is a Dockerfile for "NzbDrone" - (http://http://nzbdrone.com/)
The resulting container uses supervisor in order to restart nzbdrone after an upgrade has occur.
Specifically for use within an unRAID environment.

## Build from docker file:

```
git clone https://github.com/HurricaneHernandez/docker-nzbdrone.git 
cd docker-nzbdrone
docker build -t nzbdrone . 
```

## Volumes:

#### `/config`

Configuration files and state of NzbDrone. (i.e. /opt/appdata/NzbDrone)

#### `/mnt`

Location of mount folders, or root folder of unRAID share mount points. (i.e. /opt/downloads or /media/Tower or /mnt)


## Docker run command:

```
docker run -d --net=host -v /*your_config_location*:/config  -v /*your_mount_location*:/mnt -v /etc/localtime:/etc/localtime:ro --name=nzbdrone hurricane/docker-nzbdrone
```
