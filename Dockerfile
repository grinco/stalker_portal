FROM ubuntu:12.04 

ADD ./etc/ /etc/
WORKDIR /

# Prepare
RUN apt-get update
RUN apt-get install -y -u apt-utils unzip apache2 nginx-extras memcached mysql-client php5 php5-mysql php-pear nodejs upstart && pear channel-discover pear.phing.info && pear install phing/phing
RUN apt-get install -y -u wget cron php-soap php5-intl php-gettext php5-memcache php5-curl php5-mysql php5-tidy php5-imagick php5-geoip curl

# Unpack, install
RUN wget --no-check-certificate https://github.com/azhurb/stalker_portal/archive/master.zip
RUN unzip master.zip
RUN mv stalker_portal-master /var/www/stalker_portal/

# Copy custom.ini
ADD ./stalker_portal/ /var/www/stalker_portal

# Deploy cron jobs, etc (useless in docker)
RUN cd /var/www/stalker_portal/deploy/ && phing


EXPOSE 8080

# start the server
ADD ./init.sh /init.sh
CMD [ "/init.sh" ]
