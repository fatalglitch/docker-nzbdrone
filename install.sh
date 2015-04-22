#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
usermod -u 99 nobody
usermod -g 100 nobody
usermod -d /config nobody
mkdir -p /config
chown -R nobody:users /config

# Disable SSH
rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Repositories
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"
add-apt-repository "deb http://apt.sonarr.tv/ master main"
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC

# Install Dependencies
apt-get update -qq
apt-get install -qy libgdiplus libmono-cil-dev


#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################
# CONFIG
cat <<'EOT' > /etc/my_init.d/01_config.sh
#!/bin/bash
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  DEBIAN_FRONTEND="noninteractive" dpkg-reconfigure -f noninteractive tzdata
fi
EOT

# Sonarr Config
cat <<'EOT' > /etc/my_init.d/01_Sonarr_config.sh
#!/bin/bash
echo "Configuring Options for Sonarr container."
PORT=${SR_PORT:-8083}
if [ -f /config/config.xml ]; then
        echo "Config exists, editing it."
        sed -i -e 's%<Port>.*</Port>%<Port>${PORT}</Port>%' /config/config.xml
        sed -i -e 's%<UpdateMechanism>.*</UpdateMechanism>%<UpdateMechanism>Script</UpdateMechanism>%' /config/config.xml
        sed -i -e 's%<UpdateScriptPath>.*</UpdateScriptPath>%<UpdateScriptPath>/scripts/sonarr-update.sh</UpdateScriptPath>%' /config/config.xml
else
        echo "Creating a basic config file."
        cp /tmp/config.xml /config/config.xml
fi
echo "Using following config options:"
cat /config/config.xml

# Adjust UID and GID of nobody with environmet variables
echo "Adjusting UID and GID of nobody with provided environment variables or defaults."
USER_ID=${SR_USER_ID:-99}
GROUP_ID=${SR_GROUP_ID:-100}
groupmod -g $GROUP_ID users
usermod -u $USER_ID nobody
usermod -g $GROUP_ID nobody
usermod -d /home nobody
chown -R nobody:users /opt/NzbDrone /scripts/ /config/
echo "Done."
EOT

# Upgrade script
mkdir -p /scripts
cat <<'EOT' > /scripts/sonarr-update.sh
#!/bin/bash

# 52 /tmp/nzbdrone_update /opt/NzbDrone/NzbDrone.exe

echo "updating Sonarr"
rm -Rfv /opt/NzbDrone/*
mv /tmp/nzbdrone_update/NzbDrone/* /opt/NzbDrone/

echo "Using runnit to restart sonarr"
sv restart Sonarr
EOT

# Default Sonarr Config
cat <<'EOT' > /tmp/config.xml
<Config>
  <Port>8083</Port>
  <SslPort>9898</SslPort>
  <EnableSsl>False</EnableSsl>
  <LaunchBrowser>False</LaunchBrowser>
  <Branch>master</Branch>
  <LogLevel>Debug</LogLevel>
  <SslCertHash>
  </SslCertHash>
  <UrlBase>
  </UrlBase>
  <UpdateMechanism>Script</UpdateMechanism>
  <UpdateAutomatically>True</UpdateAutomatically>
  <UpdateScriptPath>/scripts/sonarr-update.sh</UpdateScriptPath>
  <BindAddress>*</BindAddress>
</Config>
EOT

mkdir -p /etc/service/Sonarr
cat <<'EOT' > /etc/service/Sonarr/run
#!/bin/bash
exec 2>&1 

exec /sbin/setuser nobody mono /opt/NzbDrone/NzbDrone.exe -nobrowswer -data=/config
EOT

chmod +x /etc/service/*/run /etc/my_init.d/* /scripts/*

#########################################
##             INSTALLATION            ##
#########################################

# Install Sonarr
apt-get install -qy nzbdrone

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/*
