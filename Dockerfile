FROM php:5-apache

ADD ./etc/ /etc/
WORKDIR /

# Prepare
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install -y -u apt-utils unzip mysql-client nodejs upstart wget curl cron

# Missing devel packages for the PHP modules installation
RUN apt-get install -y icu-devtools libxml2-dev
RUN apt-get install -y libcurl4-nss-dev libtidy-dev
RUN apt-get install -y libpng-dev libicu-dev

# Install PHP modules
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install soap
RUN docker-php-ext-install intl
RUN docker-php-ext-install gettext
RUN docker-php-ext-install curl
RUN docker-php-ext-install tidy
RUN docker-php-ext-install gd
RUN docker-php-ext-install pdo_mysql

# Set PHP time zone
RUN echo date.timezone="UTC" > /usr/local/etc/php/conf.d/timezone.ini 

# Unpack, install
ADD ./src/stalker_portal-5.2.0.zip /tmp/stalker_portal-5.2.0.zip
RUN unzip /tmp/stalker_portal-5.2.0.zip
RUN mv infomirgroup-stalker_portal-9e60f9025ab6 /var/www/html/stalker_portal/
RUN rm /tmp/stalker_portal-5.2.0.zip

# Install and configure apache cloudflare module
RUN wget https://www.cloudflare.com/static/misc/mod_cloudflare/ubuntu/mod_cloudflare-trusty-amd64.latest.deb -O /tmp/mod_cloudflare-trusty-amd64.latest.deb
RUN dpkg -i /tmp/mod_cloudflare-trusty-amd64.latest.deb
RUN sed -i -e 's/CloudFlareRemoteIPTrustedProxy/CloudFlareRemoteIPTrustedProxy 172.16.0.0\/12 192.168.0.0\/16 10.0.0.0\/8/' /etc/apache2/mods-enabled/cloudflare.conf

# Enable Rewrite
RUN a2enmod rewrite

# Install PHING
RUN pear channel-discover pear.phing.info 
# RUN pear upgrade-all
RUN pear install --alldeps phing/phing

# Copy custom.ini, build.xml.
ADD ./stalker_portal/ /var/www/html/stalker_portal

# Add IonCube Loaders
RUN mkdir /tmp/ioncube_install
WORKDIR /tmp/ioncube_install
RUN wget http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -O /tmp/ioncube_install/ioncube_loaders_lin_x86-64.tar.gz
RUN tar zxf /tmp/ioncube_install/ioncube_loaders_lin_x86-64.tar.gz
RUN mv /tmp/ioncube_install/ioncube/ioncube_loader_lin_5.6.so /usr/local/lib/php/extensions/no-debug-non-zts-20131226/
RUN rm -rf /tmp/ioncube_install
RUN echo "zend_extension = /usr/local/lib/php/extensions/no-debug-non-zts-20131226/ioncube_loader_lin_5.6.so" >> /usr/local/etc/php/conf.d/00-ioncube.ini

# Deploy stalker
RUN cd /var/www/html/stalker_portal/deploy/ && phing

# Finish installing broken packages
RUN apt-get install -f -y
RUN apt-get autoremove -y

EXPOSE 80

CMD ["apache2-foreground"]

WORKDIR /var/www/html/

VOLUME ["/var/www/html/"]
