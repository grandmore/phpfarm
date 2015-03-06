#
# PHP Farm for wordpress testing
#

# we use Debian as the host OS
FROM debian:wheezy

MAINTAINER Stuart Fenton <stuart@overlima.com>

# add some build tools
RUN apt-get update && \
    apt-get install -y \
    autoconf \
    apache2 \
    apache2-mpm-prefork \
    git \
    build-essential \
    mysql-client \
    libmysqlclient-dev \
    mysql-server \
    wget \
    libxml2-dev \
    libssl-dev \
    libsslcommon2-dev \
    libcurl4-openssl-dev \
    pkg-config \
    curl \
    libapache2-mod-fcgid \
    libbz2-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libxpm-dev \
    libmcrypt-dev \
    libt1-dev \
    libltdl-dev \
    libmhash-dev

# install and run the phpfarm script
RUN git clone git://git.code.sf.net/p/phpfarm/code phpfarm

# add customised configuration
COPY phpfarm /phpfarm/src/

# compile, then delete sources (saves space)
RUN cd /phpfarm/src && \
	./compile.sh 5.2.17 && \
	./compile.sh 5.3.29 && \
	./compile.sh 5.4.32 && \
	./compile.sh 5.5.16 && \
	./compile.sh 5.6.1 
#	rm -rf /phpfarm/src && \
#	apt-get clean && \
# 	rm -rf /var/lib/apt/lists/*

# xdebug 5.2.17
RUN cd /phpfarm/inst/php-5.2.17 && \
	wget http://xdebug.org/files/xdebug-2.2.7.tgz && \
	tar -zxf xdebug-2.2.7.tgz && \
	cd xdebug-2.2.7 && \
	/phpfarm/inst/php-5.2.17/bin/phpize && \
	./configure --enable-xdebug --with-php-config=/phpfarm/inst/php-5.2.17/bin/php-config && \
	make install
RUN echo 'zend_extension="/phpfarm/inst/php-5.2.17/lib/php/extensions/debug-non-zts-20060613/xdebug.so"' >> '/phpfarm/inst/php-5.2.17/lib/php.ini'

# xdebug 5.3.29
RUN cd /phpfarm/inst/php-5.3.29 && \
	wget http://xdebug.org/files/xdebug-2.2.7.tgz && \
	tar -zxf xdebug-2.2.7.tgz && \
	cd xdebug-2.2.7 && \
	/phpfarm/inst/php-5.3.29/bin/phpize && \
	./configure --enable-xdebug --with-php-config=/phpfarm/inst/php-5.3.29/bin/php-config && \
	make install	
RUN echo 'zend_extension="/phpfarm/inst/php-5.3.29/lib/php/extensions/debug-non-zts-20090626/xdebug.so"' >> '/phpfarm/inst/php-5.3.29/lib/php.ini'

# xdebug 5.4.32
RUN cd /phpfarm/inst/php-5.4.32 && \
	wget http://xdebug.org/files/xdebug-2.2.7.tgz && \
	tar -zxf xdebug-2.2.7.tgz && \
	cd xdebug-2.2.7 && \
	/phpfarm/inst/php-5.4.32/bin/phpize && \
	./configure --enable-xdebug --with-php-config=/phpfarm/inst/php-5.4.32/bin/php-config && \
	make install	
RUN echo 'zend_extension="/phpfarm/inst/php-5.4.32/lib/php/extensions/debug-non-zts-20100525/xdebug.so"' >> '/phpfarm/inst/php-5.4.32/lib/php.ini'


# xdebug 5.5.16
RUN cd /phpfarm/inst/php-5.5.16 && \
	wget http://xdebug.org/files/xdebug-2.2.7.tgz && \
	tar -zxf xdebug-2.2.7.tgz && \
	cd xdebug-2.2.7 && \
	/phpfarm/inst/php-5.5.16/bin/phpize && \
	./configure --enable-xdebug --with-php-config=/phpfarm/inst/php-5.5.16/bin/php-config && \
	make install	
RUN echo 'zend_extension="/phpfarm/inst/php-5.5.16/lib/php/extensions/debug-non-zts-20121212/xdebug.so"' >> '/phpfarm/inst/php-5.5.16/lib/php.ini'

# xdebug 5.6.1
RUN cd /phpfarm/inst/php-5.6.1 && \
	wget http://xdebug.org/files/xdebug-2.2.7.tgz && \
	tar -zxf xdebug-2.2.7.tgz && \
	cd xdebug-2.2.7 && \
	/phpfarm/inst/php-5.6.1/bin/phpize && \
	./configure --enable-xdebug --with-php-config=/phpfarm/inst/php-5.6.1/bin/php-config && \
	make install	
RUN echo 'zend_extension="/phpfarm/inst/php-5.6.1/lib/php/extensions/debug-non-zts-20131226/xdebug.so"' >> '/phpfarm/inst/php-5.6.1/lib/php.ini'



#RUN apt-get clean

RUN curl http://get.zedapp.org | bash

# add a symbolic link to php 5.3
RUN ln -s /phpfarm/inst/bin/php-5.3.29 /usr/bin/php

# reconfigure Apache
RUN rm -rf /var/www/*

COPY var-www /var/www/
COPY apache  /etc/apache2/

RUN a2ensite php-5.2 php-5.3 php-5.4 php-5.5 php-5.6
RUN a2enmod rewrite

# set path
ENV PATH /phpfarm/inst/bin/:/usr/sbin:/usr/bin:/sbin:/bin

# expose the ports
EXPOSE 8052 8053 8054 8055 8056

# run it
COPY run.sh /run.sh
ENTRYPOINT ["/bin/bash"]
CMD ["/run.sh"]
