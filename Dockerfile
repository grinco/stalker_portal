FROM ubuntu:14.04 

ADD ./etc/ /etc/
WORKDIR /

# Prepare
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y -u apt-utils unzip apache2 nginx-extras memcached mysql-client php5 php5-mysql php-pear nodejs upstart wget cron php-soap php5-intl php-gettext php5-memcache php5-curl php5-mysql php5-tidy php5-imagick php5-geoip curl

# Unpack, install
RUN wget --no-check-certificate https://github.com/azhurb/stalker_portal/archive/master.zip
RUN unzip master.zip
RUN mv stalker_portal-master /var/www/html/stalker_portal/
RUN rm /etc/nginx/sites-avaliable/default

# Add IonCube Loaders
RUN mkdir /tmp/ioncube_install
WORKDIR /tmp/ioncube_install
RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O /tmp/ioncube_install/ioncube_loaders_lin_x86-64.tar.gz
RUN tar zxf /tmp/ioncube_install/ioncube_loaders_lin_x86-64.tar.gz
RUN mv /tmp/ioncube_install/ioncube/ioncube_loader_lin_5.5.so /usr/lib/php5/20121212s
RUN rm -rf /tmp/ioncube_install
RUN echo "zend_extension = /usr/lib/php5/20121212/ioncube_loader_lin_5.5.so" >> /etc/php5/apache2/conf.d/00-ioncube.ini




# Install PHING
RUN pear channel-discover pear.phing.info && pear upgrade-all
RUN pear install --alldeps phing/phing

# Copy custom.ini, build.xml.
ADD ./stalker_portal/ /var/www/html/stalker_portal

# Deploy cron jobs, etc (useless in docker)
RUN cd /var/www/html/stalker_portal/deploy/ && phing

EXPOSE 8080

# start the server
ADD ./init.sh /init.sh
CMD [ "/init.sh" ]
