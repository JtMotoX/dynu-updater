#!/bin/sh

touch /data/dynu-updater.log
tail -f -n0 /data/dynu-updater.log &

touch /tmp/crond.log
tail -f /tmp/crond.log &

crond -f -l 8 -L /tmp/crond.log
