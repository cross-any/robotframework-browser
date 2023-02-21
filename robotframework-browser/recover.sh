#!/bin/bash
set -e
# set -x
PID=$1
shift
for f in $@; do
    if [ ! -e $f ]; then
        fd=$(ls -l /proc/$PID/fd/|grep "$f (deleted)"|awk '{print $9}'|tail -1)
        mkdir -p $(dirname $f)
        echo recover /proc/$PID/fd/$fd to $f
        tail -q -c +0 --follow=name /proc/$PID/fd/$fd >$f </dev/null  &
        # tail -q -c +0 /proc/$PID/fd/$fd >$f </dev/null
        # cat /proc/$PID/fd/$fd >$f </dev/null
    fi
done