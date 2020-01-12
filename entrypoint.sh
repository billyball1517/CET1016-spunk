#!/bin/bash

/usr/sbin/snmpd -LS0-6d -f &
/opt/splunk/bin/splunk start --accept-license &

exec gosu root "$@"
