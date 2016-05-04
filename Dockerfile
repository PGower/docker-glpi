FROM ubuntu:14.04
MAINTAINER Paul Gower <pgower@stmonicas.qld.edu.au>

# setup workdir
WORKDIR /var/www

# environment for osticket
ENV GLPI_VERSION 0.90.3
ENV HOME /var/www

# requirements
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
  wget \
  tar \
  gzip \
  msmtp \
  ca-certificates \
  supervisor \
  apache2 \
  php5-cli \
  php5-imap \
  php5-gd \
  php5-curl \
  php5-ldap \
  php5-mysql \
  libapache2-mod-php5 && \
  rm -rf /var/lib/apt/lists/*

# Download & Install confd
RUN wget -nv -O /bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.11.0/confd-0.11.0-linux-amd64 && \
    chmod +x /bin/confd && \
    mkdir -p /etc/confd/conf.d && \
    mkdir -p /etc/confd/templates 

# Download & Install GLPI
RUN wget -nv -O glpi.tar.gz https://github.com/glpi-project/glpi/releases/download/${GLPI_VERSION}/glpi-${GLPI_VERSION}.tar.gz && \
    tar -xzf glpi.tar.gz && \
    rm glpi.tar.gz && \
    chown -R www-data:www-data glpi

# Enable PHP5 modules
RUN php5enmod imap && \
    php5enmod ldap

ADD supervisord.conf /supervisord.conf
ADD start.sh /start.sh
RUN chmod +x /start.sh
ADD conf.d/ /etc/confd/conf.d
ADD templates /etc/confd/templates

VOLUME ["/var/log/nginx"]
EXPOSE 80
CMD ["/start.sh"]
