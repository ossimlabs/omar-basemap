#!/bin/bash
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)
sed '/^omar/d' /etc/passwd > /tmp/passwd
echo omar:x:$USER_ID:$GROUP_ID:Default Application User:$HOME:/sbin/nologin >> /tmp/passwd

export LD_PRELOAD=/usr/lib64/libnss_wrapper.so
export NSS_WRAPPER_PASSWD=/tmp/passwd
export NSS_WRAPPER_GROUP=/etc/group

start-stop-daemon --start --pidfile /home/omar/xvfb.pid --make-pidfile --background --exec /usr/bin/Xvfb -- :99 -screen 0 1024x768x24 -ac +extension GLX +render -noreset
sleep 1

export DISPLAY=:99.0

cd /data
node /home/omar -p 8080 "$@"
