#!/bin/sh
cat /root/.ssh/authorized_keys
chown root:root /root/.ssh/authorized_keys
chmod 700 /root/.ssh
chmod 640 /root/.ssh/authorized_keys
/usr/sbin/sshd -D
