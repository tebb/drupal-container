##
# LocalGovDrupal web container.

FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

# Install packages.
RUN apt-get update && \
    apt-get install -y \
      apache2 \
      curl \
      libapache2-mod-php7.2 \
      mysql-client \
      patch \
      php7.2 \
      php7.2-cli \
      php7.2-common \
      php7.2-curl \
      php7.2-json \
      php7.2-gd \
      php7.2-mbstring \
      php7.2-mysql \
      php7.2-opcache \
      php7.2-xml \
      php7.2-zip \
      php-memcached  && \
    apt-get clean

# Add a docker user
RUN useradd -m -s /bin/bash -G www-data -p docker docker

# Configure Apache.
ENV APACHE_RUN_USER docker
ENV APACHE_RUN_GROUP docker
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
COPY config/apache2/docker.conf /etc/apache2/conf-available/docker.conf
COPY config/apache2/vhost.conf /etc/apache2/sites-available/vhost.conf
RUN a2enmod \
      expires \
      headers \
      rewrite && \
    a2dissite 000-default.conf && \
    a2ensite vhost.conf && \
    ln -s /etc/apache2/conf-available/docker.conf /etc/apache2/conf-enabled/docker.conf && \
    rm -fr /var/www/*

# Configure PHP.
COPY config/php/docker.ini /etc/php/7.2/conf.d/docker.ini
RUN ln -s /etc/php/7.2/conf.d/docker.ini /etc/php/7.2/apache2/conf.d/90-docker.ini

# Install Composer,
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

EXPOSE 80

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
