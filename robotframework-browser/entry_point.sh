#!/bin/bash
set -e
trap "pkill ffmpeg" INT TERM EXIT
# set -x
mkdir -p robot_logs
env|grep -vf /ignored-envs.txt
echo "$@"
ip addr
mkdir -p /var/run/sshd
/usr/sbin/sshd &>/dev/null 2>/dev/null &
GEOMETRY="${SCREEN_WIDTH:-1280}x${SCREEN_HEIGHT:-768}x${SCREEN_DEPTH:-16}"
Xvfb :99 -screen 0 $GEOMETRY &>/dev/null </dev/null &
jwm &>/dev/null 2>/dev/null &
x11vnc -ncache 10 -listen 0.0.0.0 -rfbport 5900 -noipv6 -display $DISPLAY -forever &>/dev/null  </dev/null &
/opt/bin/noVNC/utils/novnc_proxy --listen 7900 --vnc localhost:5900 &>/dev/null  </dev/null &
if [ -n "$FRPC" -a -e "$FRPC" ]; then
  frpc -c $FRPC &>/dev/null  </dev/null &
else
  echo frpc配置文件${FRPC}不存在,不映射端口
fi
if [ -n "$RECORD" ]; then
  ffmpeg -f x11grab -i :99 -y -pix_fmt yuv420p "$RECORD" &>robot_logs/record.log  </dev/null &
fi
if [ -e /tests/requirements-$BASE_LIBRARY.txt ]; then
    pip install -r /tests/requirements-$BASE_LIBRARY.txt
fi
if [ -e /tests/requirements.txt ]; then
    pip install -r /tests/requirements.txt
fi
if [ "$1" = "node" -a ! -z $GRUD_REGISTER_URL ]; then
  shift
  java -jar /opt/selenium/selenium-server-standalone-3.141.59.jar -role node -hub $GRUD_REGISTER_URL "$@"
elif [ "$1" = "hub" ]; then
  shift
  java -jar /opt/selenium/selenium-server-standalone-3.141.59.jar -role hub $@
elif [ 0$PROCESSES -gt 1  -o "$1" = "pabot" ]; then
  shift
  PROCESSES=${PROCESSES:-3}
  pabot --verbose --processes $PROCESSES -d robot_logs $@| sed ''s/\ PASS\ /\ `printf "\033[32mPASS\033[0m"`\ /g''|sed ''s/\ FAIL\ /\ `printf "\033[31mFAIL\033[0m"`\ /g''
elif [ 0$PROCESSES -gt 1  -o "$1" = "pabotselenium" ]; then
  java -jar /opt/selenium/selenium-server-standalone-3.141.59.jar -role hub 2>/dev/null&
  java -jar /opt/selenium/selenium-server-standalone-3.141.59.jar -role node 2>/dev/null&
  
  url=http://localhost:4444/grid/console
  loops=0
  until [ $(curl -k $url 2>/dev/null|grep "role: node"|wc -l) -ge $PROCESSES ]
  do
    slept=$(expr $loops \* 2)
    if [ $slept -lt 40 ]; then
        sleep 2
        echo Wait for seleium nodes
        loops=$(expr $loops + 1)
    else
        >&2 echo Timeouted
        exit 1
    fi
  done

  pabot --verbose --processes $PROCESSES -d /out "$@"| sed ''s/\ PASS\ /\ `printf "\033[32mPASS\033[0m"`\ /g''|sed ''s/\ FAIL\ /\ `printf "\033[31mFAIL\033[0m"`\ /g''
elif [ "$1" = "robot" ]; then
  shift
  robot -d robot_logs "$@"
elif [ "$1" = "npx" ]; then
  npm install
  bash -c "$@"
else
  bash -c "$@"
fi
