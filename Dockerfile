# Builds a docker image for NzbDrone
FROM ubuntu:trusty
MAINTAINER Carlos Hernandez <carlos@techbyte.ca>

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

# Set user nobody to uid and gid of unRAID
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

# Set locale
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8
RUN dpkg-reconfigure locales

# Update Ubuntu
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys FDA5DFFC && \
  echo 'deb http://update.nzbdrone.com/repos/apt/debian master main' > /etc/apt/sources.list.d/nzbdrone.list
RUN apt-get -q update
RUN apt-mark hold initscripts udev plymouth mountall
RUN apt-get -qy --force-yes dist-upgrade

# Install nzbdrone 
RUN usermod -m -d /config nobody
RUN apt-get install -qy --force-yes libmono-cil-dev nzbdrone supervisor && chown -R nobody:users /opt/NzbDrone
RUN mkdir /scripts && chown -R nobody:users /scripts

# Add config files
ADD ./files/supervisord.conf /etc/supervisor/supervisord.conf
ADD ./files/nzbdrone-supervisor.conf /etc/supervisor/conf.d/nzbdrone.conf
ADD ./files/sonnar-update.sh /scripts/sonnar-update.sh
ADD ./files/start.sh /start.sh
RUN chmod a+x  /start.sh
RUN chmod a+x /scripts/sonnar-update.sh

VOLUME /config

ENTRYPOINT ["/start.sh"]
