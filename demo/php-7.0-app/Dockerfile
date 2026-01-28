FROM php:7.0-cli-alpine

WORKDIR /app

# Install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

COPY composer.json .
# Allow composer to run as root and ignore platform requirements if necessary (though we want to enforce them)
# Note: In docker 7.0 env, platform reqs should match.
RUN composer install --no-scripts --no-autoloader

COPY . .
RUN composer dump-autoload --optimize

CMD ["./vendor/bin/phpunit"]
