FROM centos:8

# Upgrade System
RUN yum upgrade -y

# Install gosu
COPY --from=gosu/assets /opt/gosu /opt/gosu
RUN set -x \
    && /opt/gosu/gosu.install.sh \
    && rm -fr /opt/gosu

# Splunk Install
RUN yum install -y passwd wget tar initscripts \
    && groupadd splunk \
    && useradd -d /opt/splunk -m -g splunk splunk \
    && echo splunk | passwd splunk --stdin \
    && wget -O splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.0.1&product=splunk&filename=splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz&wget=true' \
    && tar -xzvf splunk-8.0.1-6db836e2fb9e-Linux-x86_64.tgz \
    && cp -rp splunk/* /opt/splunk \
    && rm -rf splunk \
    && chown -R splunk: /opt/splunk \
    && /opt/splunk/bin/splunk cmd splunkd rest --noauth POST /services/authentication/users "name=splunk&password=splunkpass&roles=admin" \
    && yum install -y net-snmp net-snmp-utils \
    && snmptrapd -Lf /var/log/snmp-traps --disableAuthorization=yes

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD tail -f /dev/null
