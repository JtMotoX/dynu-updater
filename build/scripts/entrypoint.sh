#!/bin/sh

touch /var/log/dynu-updater/dynu-updater.log
tail -f -n0 /var/log/dynu-updater/dynu-updater.log &

touch /tmp/crond.log
tail -f /tmp/crond.log &

crond -f -l 8 -L /tmp/crond.log
