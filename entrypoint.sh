#!/bin/bash

/opt/splunk/bin/splunk start --accept-license &
/opt/splunk/bin/splunk cmd splunkd rest --noauth POST /services/authentication/users "name=splunk&password=splunkpass&roles=admin" &
/opt/splunk/bin/splunk start --accept-license &

/usr/sbin/snmpd -LS0-6d -f &

exec gosu root "$@"
