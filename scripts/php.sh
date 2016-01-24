#!/usr/bin/env bash

export LANG=C.UTF-8

PHP_TIMEZONE=$1
HHVM=$2
PHP_VERSION=$3

if [[ $HHVM == "true" ]]; then

    echo ">>> Installing HHVM"

    # Get key and add to sources
    wget --quiet -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
    echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list

    # Update
    sudo apt-get update

    # Install HHVM
    # -qq implies -y --force-yes
    sudo apt-get install -qq hhvm

    # Start on system boot
    sudo update-rc.d hhvm defaults

    # Replace PHP with HHVM via symlinking
    sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60

    sudo service hhvm restart
else
    echo ">>> Installing PHP $PHP_VERSION"

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

    if [ $PHP_VERSION == "5.5" ]; then
        # Add repo for PHP 5.5
        sudo add-apt-repository -y ppa:ondrej/php5
    else
        # Add repo for PHP 5.6
        sudo add-apt-repository -y ppa:ondrej/php5-5.6
    fi

    sudo apt-key update
    sudo apt-get update

    # Install PHP
    # -qq implies -y --force-yes
    sudo apt-get install -qq php5 dh-make-php php5-dev php5-curl php5-gd php5-gmp php5-imap php5-mysql php5-mcrypt php5-tidy php5-intl php5-cli

    # PHP Error Reporting Config
    sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/fpm/php.ini
    sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/fpm/php.ini

    # PHP Date Timezone
    sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php5/fpm/php.ini
    sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php5/cli/php.ini

    sudo service php5-fpm restart
fi
