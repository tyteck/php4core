FROM    php:7.3-cli

# ====================================================
# this image will produce one php 7.2 cli which will include everything 
# needed to run pmt core.

LABEL   maintainer="Frederick Tyteca"

ENV     DEBIAN_FRONTEND=noninteractive

# ====================================================
# things to add 
# git : used by gitlab-ci
# ffmpeg : required by youtube-dl
# python3 : required by youtube-dl
# wget : to add composer/youtube-dl
# zip : used by composer install
# locales : to set locales (logale-gen not found else)
# msmtp : to send mail (replace ssmtp)
RUN     apt-get update -y && \
        apt-get install -y --no-install-recommends \
                git \
                ffmpeg \
                python3 \
                wget \
                zip \
				unzip \
				zlib1g-dev \ 
				libzip-dev\
                locales \
                msmtp && \
        rm -rf /var/lib/apt/lists/*;

# installing required php modules
RUN     docker-php-ext-install pdo pdo_mysql mysqli zip

# ====================================================
# setting timezone && locale

RUN     sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        dpkg-reconfigure --frontend=noninteractive locales && \
        update-locale LANG=en_US.UTF-8

ENV     TZ="Europe/Paris" \
        LANG="en_US.UTF-8" \
        LANGUAGE="en_US:en" \
        LC_ALL="en_US.UTF-8"
RUN     ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
        echo $TZ > /etc/timezone 

# Install composer dependencies
COPY    ./installComposer.sh /var/opt/installComposer.sh
RUN     chmod +x /var/opt/installComposer.sh
RUN     /var/opt/installComposer.sh
