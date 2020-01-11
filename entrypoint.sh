#!/bin/bash

service snmpd start \
/opt/splunk/bin/splunk start --accept-license

exec /usr/sbin/gosu root "$@"
