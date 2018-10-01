#!/bin/bash
# Disabling SeLinux for installation(Remains disabled untill reboot ar manual enable). 
setenforce 0

# Opening TCP port 80 fro administration interface access
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

# Updating packages
yum -y update

# Installing needed tools and packages
yum -y groupinstall core base "Development Tools"

#Installing additional required dependencies
yum -y install lynx tftp-server unixODBC mysql-connector-odbc mariadb-server mariadb httpd ncurses-devel sendmail sendmail-cf sox newt-devel libxml2-devel libtiff-devel audiofile-devel gtk2-devel subversion kernel-devel git crontabs cronie cronie-anacron wget vim uuid-devel sqlite-devel net-tools gnutls-devel python-devel texinfo

#Installing php 5.6 repositories
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# Install php5.6w
yum remove php*
yum install php56w php56w-pdo php56w-mysql php56w-mbstring php56w-pear php56w-process php56w-xml php56w-opcache php56w-ldap php56w-intl php56w-soap

#Installing nodejs
curl -sL https://rpm.nodesource.com/setup_8.x | bash -
yum install -y nodejs

# Enabling and starting MariaDB
systemctl enable mariadb.service
systemctl start mariadb

# MariaDB post install configuration
mysql_secure_installation

# Enabling and starting Apache
systemctl enable httpd.service
systemctl start httpd.service

# Installing Legacy Pear requirements
pear install Console_Getopt

#Installing Dependencies for Google Voice if needed
#Installing iksemel
echo "Do you plan to use Google Voice?"
select yn in "Yes" "No"; do
    case $yn in
            Yes ) cd /usr/src; wget https://github.com/meduketto/iksemel/archive/master.zip -O iksemel-master.zip; unzip iksemel-master.zip; rm -f iksemel-master.zip; cd iksemel-master; ./autogen.sh; ./configure; make; make install; break;;
			No ) break;;
    esac
done

# Compiling and Installing jansson
cd /usr/src
wget -O jansson.zip https://codeload.github.com/akheron/jansson/zip/master
unzip jansson.zip
rm -f jansson.zip
cd jansson-*
autoreconf -i
./configure --libdir=/usr/lib64
make
make install

#Compile and install DAHDI if needed
#If you don't have any physical PSTN hardware attached to this machine, you don't need to install DAHDI (For example, a T1 or E1 card, or a USB device). Most smaller setups will not have DAHDI hardware, and this step can be safely skipped.
echo "Do you have PSTN hardare and want to use DAHDI?"
select yn in "Yes" "No"; do
    case $yn in
            Yes ) cd /usr/src; wget http://downloads.asterisk.org/pub/telephony/dahdi-linux-complete/dahdi-linux-complete-current.tar.gz; wget http://downloads.asterisk.org/pub/telephony/libpri/libpri-current.tar.gz; tar xvfz dahdi-linux-complete-current.tar.gz; tar xvfz libpri-current.tar.gz; rm -f dahdi-linux-complete-current.tar.gz libpri-current.tar.gz; cd dahdi-linux-complete-*; make all; make install; make config; cd /usr/src/libpri-*; make; make install; break;;
            No ) break;;
    esac
done

# Preparing for Asterisk installation
adduser asterisk -m -c "Asterisk User"

# Downloading Asterisk source files.
cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-14-current.tar.gz

# Compiling and installing Asterisk
cd /usr/src
tar xvfz asterisk-14-current.tar.gz
rm -f asterisk-14-current.tar.gz
cd asterisk-*
contrib/scripts/install_prereq install
./configure --libdir=/usr/lib64 --with-pjproject-bundled
contrib/scripts/get_mp3_source.sh

# Making some configuration of installation options, modules, etc. After selecting 'Save & Exit' you can then continue
make menuselect

# Installation itself
make
make install
make config
ldconfig
systemctl disable asterisk

# Setting Asterisk ownership permissions.
chown asterisk. /var/run/asterisk
chown -R asterisk. /etc/asterisk
chown -R asterisk. /var/{lib,log,spool}/asterisk
chown -R asterisk. /usr/lib64/asterisk
chown -R asterisk. /var/www/

# Preparing for FreePBX installation. A few small modifications to Apache and PHP.
sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php.ini
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/httpd/conf/httpd.conf
systemctl restart httpd.service

# Download and install FreePBX.
cd /usr/src
wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-14.0-latest.tgz
tar xfz freepbx-14.0-latest.tgz
rm -f freepbx-14.0-latest.tgz
cd freepbx
./start_asterisk start
./install -n
