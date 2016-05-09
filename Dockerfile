# ------------------------------------------------------------------------------
# Based on a work at https://github.com/docker/docker.
# Forked from https://github.com/kdelfour/cloud9-docker
# ------------------------------------------------------------------------------
# Pull base image.
FROM kdelfour/supervisor-docker
MAINTAINER Ivan Kristianto <ivan@ivankristianto.com>

# ------------------------------------------------------------------------------
# Install base
RUN apt-get update
RUN apt-get install -y build-essential g++ curl libssl-dev apache2-utils git libxml2-dev sshfs

# ------------------------------------------------------------------------------
# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup | bash -
RUN apt-get install -y nodejs
    
# ------------------------------------------------------------------------------
# Install Cloud9
RUN git clone -b master --depth=1 https://github.com/c9/core.git /cloud9
WORKDIR /cloud9
RUN scripts/install-sdk.sh

# Tweak standlone.js conf
RUN sed -i -e 's_127.0.0.1_0.0.0.0_g' /cloud9/configs/standalone.js 

# Add supervisord conf
ADD conf/cloud9.conf /etc/supervisor/conf.d/

# ------------------------------------------------------------------------------
# Add volumes
RUN mkdir /workspace
VOLUME /workspace

# ------------------------------------------------------------------------------
# Add php5 and apache

apt-get -y install php5 apache2 libapache2-mod-php5 php5-mcrypt vim curl php5-cli
a2enmod headers; a2enmod dir; service apache2 stop

WORKDIR /opt/ 
git clone https://github.com/julianbrowne/apache-anywhere.git
COPY conf/apache bin/apache
COPY conf/httpd.conf config/httpd.conf

# ------------------------------------------------------------------------------
# Add gulp
npm install -g gulp

# ------------------------------------------------------------------------------
# Add composer
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

# ------------------------------------------------------------------------------
# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ------------------------------------------------------------------------------
# Expose ports.
EXPOSE 80
EXPOSE 3000

# ------------------------------------------------------------------------------
# Start supervisor, define default command.
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]
