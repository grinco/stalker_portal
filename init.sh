#!/bin/bash
service cron start
service memcached start
#/etc/init.d/nginx start
#/etc/init.d/apache2 start
apachectl -X
