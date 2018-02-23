FROM phusion/baseimage:0.10.0
# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

ENV DEBIAN_FRONTEND noninteractive

# Install Apache2, PHP and LTB ssp
RUN apt-get update && apt-get install -y apache2 php7.0 php7.0-mcrypt php7.0-ldap libapache2-mod-php7.0 php7.0-xml php7.0-mbstring && apt-get clean
RUN curl -L https://ltb-project.org/archives/self-service-password_1.2-1_all.deb > self-service-password.deb && dpkg -i self-service-password.deb ; rm -f self-service-password.deb

# Configure self-service-password site
RUN ln -sf /etc/php/7.0/mods-available/mcrypt.ini /etc/php/7.0/apache2/conf.d/20-mcrypt.ini
RUN a2dissite 000-default && a2ensite self-service-password

# This is where configuration goes
ADD assets/config.inc.php /usr/share/self-service-password/conf/config.inc.php

# Start Apache2 as runit service
RUN mkdir /etc/service/apache2
ADD assets/apache2.sh /etc/service/apache2/run

# Add Vault logo and favicon
ADD assets/vault.png /usr/share/self-service-password/images/vault.png
ADD assets/favicon.ico /usr/share/self-service-password/images/favicon.ico

# Fix title for the webpage
RUN sed -i 's/Self service password/Change single-factor password/g' /usr/share/self-service-password/lang/en.inc.php

EXPOSE 80
