#!/bin/sh

set -e

# give up after two minutes
TIMEOUT=120

#
# functions
#

. /usr/share/one/supervisord/service/lib/functions.sh

#
# run service
#

if [ -f /var/lib/one/.one/onegate_auth ] ; then
    msg "Found onegate_auth - we can start service"
else
    msg "No onegate_auth - wait for oned to create it..."
    if ! wait_for_file /var/lib/one/.one/onegate_auth ; then
        err "Timeout!"
        exit 1
    fi
    msg "File created - continue"
fi

msg "Service started!"
exec /usr/bin/ruby /usr/lib/one/onegate/onegate-server.rb
