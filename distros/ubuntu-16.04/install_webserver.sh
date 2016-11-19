#---------------------------------------------------------------------
# Function: InstallWebServer Debian 8
#    Install and configure Apache2, php + modules
#---------------------------------------------------------------------
InstallWebServer() {
  
  if [ "$CFG_WEBSERVER" == "apache" ]; then
	echo -n "Installing Apache and Modules... "
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
	# - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
	echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	apt-get -yqq install apache2 apache2-doc apache2-utils libapache2-mod-php  libapache2-mod-fastcgi libapache2-mod-fcgid apache2-suexec-pristine libapache2-mod-python libxml2-dev > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing PHP and Modules... "
	apt-get -yqq install php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-imap php7.0-cli php7.0-cgi php-pear php-auth php7.0-mcrypt mcrypt imagemagick libruby php7.0-curl php7.0-intl php7.0-pspell php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xmlrpc php7.0-xsl memcached php-memcache php-imagick php-gettext php7.0-zip php7.0-mbstring php7.0-fpm php7.0-opcache php-apcu> /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
	echo -n "Installing needed Programs for PHP and Apache... "
	apt-get -yqq install mcrypt imagemagick memcached curl tidy snmp > /dev/null 2>&1
    echo -e "[${green}DONE${NC}]\n"
	
  if [ "$CFG_PHPMYADMIN" == "yes" ]; then
	echo "==========================================================================================="
	echo "Attention: When asked 'Configure database for phpmyadmin with dbconfig-common?' select 'NO'"
	echo "Due to a bug in dbconfig-common, this can't be automated."
	echo "==========================================================================================="
	echo "Press ENTER to continue... "
	read DUMMY
	echo -n "Installing phpMyAdmin... "
	apt-get -y install phpmyadmin
	echo -e "[${green}DONE${NC}]\n"
  fi
	
  if [ "$CFG_XCACHE" == "yes" ]; then
	echo -n "Installing XCache... "
	apt-get -yqq install php5-xcache > /dev/null 2>&1
	echo -e "[${green}DONE${NC}]\n"
  fi
	
	echo -n "Activating Apache2 Modules... "
	a2enmod suexec > /dev/null 2>&1
	a2enmod rewrite > /dev/null 2>&1
	a2enmod ssl > /dev/null 2>&1
	a2enmod actions > /dev/null 2>&1
	a2enmod include > /dev/null 2>&1
	a2enmod dav_fs > /dev/null 2>&1
	a2enmod dav > /dev/null 2>&1
	a2enmod auth_digest > /dev/null 2>&1
	a2enmod fastcgi > /dev/null 2>&1
	a2enmod alias > /dev/null 2>&1
	a2enmod fcgid > /dev/null 2>&1
	a2enmod cgi > /dev/null 2>&1
	a2enmod headers > /dev/null 2>&1
	service apache2 restart > /dev/null 2>&1

  else
	
	echo -n "Installing NGINX and Modules... "
	service apache2 stop
	update-rc.d -f apache2 remove
	apt-get -yqq install nginx > /dev/null 2>&1
	service nginx start 
	apt-get -yqq install php5-fpm php5-mysqlnd php5-curl php5-gd php5-intl php-pear php5-imagick php5-imap php5-mcrypt php5-memcache php5-memcached php5-pspell php5-recode php5-snmp php5-sqlite php5-tidy php5-xmlrpc php5-xsl memcached php-apc > /dev/null 2>&1
	sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php5/fpm/php.ini
	sed -i "s/;date.timezone =/date.timezone=\"Europe\/Rome\"/" /etc/php5/fpm/php.ini
	#sed -i "s/#/;/" /etc/php5/conf.d/ming.ini
	service php5-fpm reload
	apt-get -yqq install fcgiwrap
	echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
    # - DISABLED DUE TO A BUG IN DBCONFIG - echo "phpmyadmin phpmyadmin/dbconfig-install boolean false" | debconf-set-selections
    echo "dbconfig-common dbconfig-common/dbconfig-install boolean false" | debconf-set-selections
	apt-get -y install phpmyadmin
    echo "With nginx phpmyadmin is accessibile at  http://$CFG_HOSTNAME_FQDN:8081/phpmyadmin or http://IP_ADDRESS:8081/phpmyadmin"
	
  fi
    echo -n "Installing Lets Encrypt... "	
	mkdir /opt/certbot > /dev/null 2>&1
	cd /opt/certbot > /dev/null 2>&1
	wget https://dl.eff.org/certbot-auto  > /dev/null 2>&1
	chmod a+x ./certbot-auto  > /dev/null 2>&1
	echo "==========================================================================================="
	echo "Attention: answer no to next Question Dialog"
	echo "==========================================================================================="
	echo "Press ENTER to continue... "
	read DUMMY
	echo -n "Installing Certbot-auto... "
	./certbot-auto
  echo -e "[${green}DONE${NC}]\n"
}
