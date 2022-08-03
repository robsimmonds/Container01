#!/bin/sh

#service mongodb start
#sleep 5
/bin/mongod --config /etc/mongodb.conf
sleep 2
su carta
pm2 start --no-daemon /usr/bin/carta-controller
