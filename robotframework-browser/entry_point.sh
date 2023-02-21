#!/bin/bash
set -e
# trap "pkill ffmpeg" INT TERM EXIT
# set -x
mkdir -p robot_logs
env|grep -vf /root/ignored-envs.txt
ip addr
id
echo "$@"
mkdir -p /var/run/sshd
/usr/sbin/sshd &>/dev/null 2>/dev/null &
GEOMETRY="${SCREEN_WIDTH:-1280}x${SCREEN_HEIGHT:-768}x${SCREEN_DEPTH:-16}"
Xvfb :99 -screen 0 $GEOMETRY &>/dev/null </dev/null &
jwmrc=/etc/system.jwmrc
if [ -e /etc/jwm/system.jwmrc ]; then
  jwmrc=/etc/jwm/system.jwmrc
fi
sed 's/format="%H:%M"/format="%H:%M:%S"/g' -i $jwmrc
sed 's/<Tray x/<Tray valign="top" x/g' -i $jwmrc
jwm >/dev/null 2>/dev/null &
watchdog() {
  while true; do
    sleep 2
    if ! (ps -ef|grep jwm|grep -v grep > /dev/null); then
      echo restart jwm
      jwm &>/dev/null 2>/dev/null &
    fi
  done
}
watchdog &>/dev/null 2>/dev/null &
x11vnc -ncache 10 -listen 0.0.0.0 -rfbport 5900 -noipv6 -display $DISPLAY -forever &>/dev/null  </dev/null &
/opt/bin/noVNC/utils/novnc_proxy --listen 7900 --vnc localhost:5900 &>/dev/null  </dev/null &
if [ -n "$FRPC" -a -e "$FRPC" ]; then
  frpc -c $FRPC &>/dev/null  </dev/null &
else
  echo frpc配置文件${FRPC}不存在,不映射端口
fi
if [ -n "$RECORD" ]; then
  RECORD_DIR=$(dirname $RECORD)
  mkdir -p $RECORD_DIR
  #create a session
  screen -d -m -S ffmpegsession
  #send the command to the session
  screen -S ffmpegsession -p 0 -X stuff "ffmpeg -f x11grab -i :99 -y -pix_fmt yuv420p /root/autotest.mp4 >/root/ffmpeg-record.log^M"
  RECORD_PATH=$(realpath $RECORD)
  RECORD_LOG_PATH=$(realpath $(dirname $RECORD)/record.log)
  #send the q string to stop ffmpeg
  trap "screen -S ffmpegsession -p 0 -X stuff \"q\";screen -S ffmpegsession -p 0 -X stuff \"exit^M\";sleep 1;/bin/mv /root/autotest.mp4 $RECORD_PATH; /bin/mv /root/ffmpeg-record.log $RECORD_LOG_PATH" INT TERM EXIT
  # ffmpeg -f x11grab -i :99 -y -pix_fmt yuv420p /root/autotest.mp4 &>/root/ffmpeg-record.log  </dev/null &
  # FFMPEGID=$(echo $!)
  # trap "/root/recover.sh $FFMPEGID $RECORD_PATH $RECORD_LOG_PATH;pkill ffmpeg" INT TERM EXIT
fi
if [ -e requirements-$BASE_LIBRARY.txt ]; then
    pip install -r requirements-$BASE_LIBRARY.txt
fi
if [ -e requirements.txt ]; then
    pip install -r requirements.txt
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
  shift
  if [ ! -e /root/.cache/ms-playwright ]; then
    mkdir -p /root/.cache && \
      ln -s /usr/local/lib/python3*/*-packages/Browser/wrapper/node_modules/playwright-core/.local-browsers/ /root/.cache/ms-playwright
  fi
  npx "$@"
else
  "$@"
fi
