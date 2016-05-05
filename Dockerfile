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

# Download Webservices Plugin for GLPI
RUN cd /var/www/glpi/plugins && \ 
    wget -nv -O webservices.tar.gz https://forge.glpi-project.org/attachments/download/2099/glpi-webservices-1.6.0.tar.gz && \
    tar -xzf webservices.tar.gz && \
    rm webservices.tar.gz && \
    chown -R www-data:www-data webservices 

# Download FusionInventory Plugin for GLPI
RUN cd /var/www/glpi/plugins && \
    wget -nv -O fusioninventory.tar.gz https://github.com/fusioninventory/fusioninventory-for-glpi/releases/download/glpi090%2B1.2/fusioninventory-for-glpi_0.90.1.2.tar.gz && \
    tar -xzf fusioninventory.tar.gz && \
    rm fusioninventory.tar.gz && \
    chown -R www-data:www-data fusioninventory

# Download FusionInventory Agents
RUN mkdir agents && \
    chown www-data:www-data agents && \
    cd agents && \
    wget -nv http://forge.fusioninventory.org/attachments/download/1890/fusioninventory-agent_windows-x64_2.3.17-portable.exe && \
    wget -nv http://forge.fusioninventory.org/attachments/download/1889/fusioninventory-agent_windows-x64_2.3.17.exe && \
    wget -nv http://forge.fusioninventory.org/attachments/download/1891/fusioninventory-agent_windows-x86_2.3.17-portable.exe && \
    wget -nv http://forge.fusioninventory.org/attachments/download/1892/fusioninventory-agent_windows-x86_2.3.17.exe

# Enable PHP5 modules
RUN php5enmod imap && \
    php5enmod ldap

ADD supervisord.conf /supervisord.conf
ADD start.sh /start.sh
RUN chmod +x /start.sh
ADD conf.d/ /etc/confd/conf.d
ADD templates /etc/confd/templates

VOLUME ["/var/log/nginx"]
EXPOSE 80 62354
CMD ["/start.sh"]
