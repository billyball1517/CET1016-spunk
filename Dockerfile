FROM centos:8

# Splunk Install
RUN yum upgrade -y \
    && yum install -y passwd wget tar \
    && groupadd splunk \
    && useradd -d /opt/splunk -m -g splunk splunk \
    && echo splunk | passwd splunk --stdin \
    && wget -O splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=splunk&filename=splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz&wget=true' \
    && tar -xzvf splunk-6.6.3-e21ee54bc796-Linux-x86_64.tgz \
    && cp -rp splunk/* /opt/splunk \
    && rm -rf splunk \
    && chown -R splunk: /opt/splunk \
    && /opt/splunk/bin/splunk cmd splunkd rest --noauth POST /services/authentication/users "name=splunk&password=splunkpass&roles=admin" \
    && yum install net-snmp net-snmp-utils \
    && snmptrapd -Lf /var/log/snmp-traps --disableAuthorization=yes

CMD service snmpd start \
    && /opt/splunk/bin/splunk start --accept-license
