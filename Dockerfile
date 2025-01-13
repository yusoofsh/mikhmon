# Startup from alpine
FROM alpine:latest
LABEL Maintainer = "Hilman Maulana, Laksamadi Guko"
LABEL Description = "MikroTik Hotspot Monitor (Mikhmon) is a web-based application (MikroTik API PHP class) to assist MikroTik Hotspot management."

# Setup document root
WORKDIR /var/www/html

# Expose the port nginx is reachable on
EXPOSE 80

# Install packages
RUN apk add --no-cache \
    nginx \
    php \
    php-fpm \
    php-gd \
    php-mbstring \
    php-mysqli \
    php-session \
    supervisor

# Configure nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY conf/fpm-pool.conf /etc/php/php-fpm.d/www.conf
COPY conf/php.ini /etc/php/conf.d/custom.ini

# Configure supervisord
COPY conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create grup and user for mikhmon
RUN addgroup mikhmon && adduser -DH -G mikhmon mikhmon

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R mikhmon:mikhmon /var/www/html /run /var/lib/nginx /var/log/nginx

# Switch to use a non-root user from here on
USER mikhmon

# Add application
COPY --chown=mikhmon src /var/www/html/

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
