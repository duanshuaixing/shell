#! /usr/bin/env bash
echo >/var/log/wtmp
echo >/var/log/btmp
echo >/var/log/secure
echo >/var/log/messages
echo >/var/log/yum.log
echo >/var/log/secure
echo >/root/.bash_history
history -c
