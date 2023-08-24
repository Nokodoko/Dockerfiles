FROM arm64v8/ubuntu:latest

RUN apt update -y && \
    apt install -y software-properties-common && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt update -y && \
    apt install -y \
    openssh-client \
    cron \
    awscli \
    apache2 \
    libapache2-mod-php7.4 \
    php7.4-fpm \
    php7.4-curl \
    php7.4-ldap \
    # php7.4-mcrypt \
    php7.4-mbstring \
    php7.4-memcache \
    php7.4-memcached \
    php7.4-opcache \
    php7.4-mysql \
    php7.4-mysqlnd \
    php7.4-xml \
    php7.4-xmlrpc \
    php7.4-zip \
    php7.4-imap \
    php7.4-soap \
    php7.4-bcmath \
    php7.4-redis && \
    a2enmod proxy_fcgi setenvif && \
    a2enmod proxy_http && \
    a2enmod headers && \
    a2enmod rewrite && \
    a2enmod ssl && \
    a2enconf php7.4-fpm

## Install LibreOffice for doc mining
RUN apt install -y libreoffice

# Add crontab file in the cron directory
ADD cron/Cronfiles /etc/cron.d/

# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/*

# Install new relic
RUN mkdir -p /opt/newrelic
WORKDIR /opt/newrelic
RUN wget -r -nd --no-parent -Alinux.tar.gz \
	http://download.newrelic.com/php_agent/release/ >/dev/null 2>&1 \
	&& tar -xzf newrelic-php*.tar.gz --strip=1
ENV NR_INSTALL_SILENT true
RUN ./newrelic-install install && \
    sed -i \
        -e "s/;\?newrelic.enabled =.*/newrelic.enabled = \${NEW_RELIC_ENABLED}/" \
        -e "s/newrelic.license =.*/newrelic.license = \${NEW_RELIC_LICENSE_KEY}/" \
        -e "s/newrelic.appname =.*/newrelic.appname = \${NEW_RELIC_APP_NAME}/" \
        /etc/php/7.4/fpm/conf.d/newrelic.ini

WORKDIR /var/www/brain

COPY . .

## add key to ssh-agent
RUN eval `ssh-agent -s` && \
    mkdir ~/.ssh && \
## change interpolation for success
    echo ${ssh_key} | base64 --decode > ~/.ssh/id_rsa && \
    chmod 0400 ~/.ssh/id_rsa && ssh-add ~/.ssh/id_rsa && \
    printf "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config

## clone jane-models via composer-install git ssh
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    composer config --no-interaction allow-plugins.kylekatarnls/update-helper true && \
    composer install && composer dump-autoload && \
    rm -rf ~/.ssh

RUN mkdir -p /var/www/brain/public/doc/uploads && \
    chown -R www-data:www-data /var/www/brain/public

RUN ln -sf /proc/self/fd/1 /var/log/apache2/brain.access.log && \
    ln -sf /proc/self/fd/2 /var/log/apache2/brain.error.log && \
    ln -sf /proc/self/fd/1 /var/log/apache2/access.log && \
    ln -sf /proc/self/fd/2 /var/log/apache2/error.log && \
    ln -sf ../mods-available/ldap.load /etc/apache2/mods-enabled && \
    ln -sf ../mods-available/ldap.conf /etc/apache2/mods-enabled && \
    ln -sf ../mods-available/authnz_ldap.load /etc/apache2/mods-enabled

RUN rm -f Dockerfile Jenkinsfile

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
