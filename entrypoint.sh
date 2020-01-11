#!/bin/bash

service snmpd start \
/opt/splunk/bin/splunk start --accept-license

exec gosu root "$@"
