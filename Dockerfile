FROM centos:8

# Upgrade System
RUN yum upgrade -y

# Install gosu
COPY --from=gosu/assets /opt/gosu /opt/gosu
RUN set -x \
    && /opt/gosu/gosu.install.sh \
    && rm -fr /opt/gosu

# Install Splunk
RUN yum install -y passwd wget tar \
    && groupadd splunk \
    && useradd -d /opt/splunk -m -g splunk splunk \
    && echo splunk | passwd splunk --stdin \
    && wget -O splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=splunk&filename=splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz&wget=true' \
    && tar -xzvf splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz \
    && cp -rp splunk/* /opt/splunk \
    && rm -rf splunk \
    && chown -R splunk: /opt/splunk \
    && echo "" >> /opt/splunk/etc/splunk-launch.conf \
    && echo "OPTIMISTIC_ABOUT_FILE_LOCKING = 1" >> /opt/splunk/etc/splunk-launch.conf
    
# Install snmp
RUN yum install -y net-snmp net-snmp-utils \
    && snmptrapd -Lf /var/log/snmp-traps --disableAuthorization=yes
    
# Install freeradius    
RUN yum -y install freeradius freeradius-utils freeradius-mysql freeradius-perl

# Install mariadb
RUN echo "[mariadb]" > etc/yum.repos.d/MariaDB.repo \
    && echo "name = MariaDB" >> etc/yum.repos.d/MariaDB.repo \
    && echo "baseurl = http://yum.mariadb.org/10.1/centos7-amd64" >> etc/yum.repos.d/MariaDB.repo \
    && echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> etc/yum.repos.d/MariaDB.repo \
    && echo "gpgcheck=1" >> etc/yum.repos.d/MariaDB.repo \
    && yum makecache \
    && yum install -y mariadb-server mariadb

# Install PHP 7
RUN yum install -y epel-release yum-utils \
    && yum install -y http://rpms.remirepo.net/enterprise/remi-release-8.rpm \
    && dnf module reset phpsudo \
    && dnf module enable php:remi-7.4 \
    && yum install -y php php-common php-opcache php-mcrypt php-cli php-gd php-curl php-mysqlnd

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD tail -f /dev/null
