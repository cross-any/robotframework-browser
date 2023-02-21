# docker build -t registry.cn-beijing.aliyuncs.com/windli/robotframework-browser-base:1.0 -f Dockerfile ..
FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="yong.li@governance-solutions.com"
ENV PATH /opt/node-v16.19.1-linux-x64/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/frp_0.47.0_linux_amd64

ENV SCREEN_WIDTH=1280 \
    SCREEN_HEIGHT=720 \
    SCREEN_DEPTH=16 \
    DISPLAY=:99 \
    PYTHONWARNINGS=ignore \
    WEBKIT_DEPS="libgbm1 libxkbcommon0" \
    FIREFOX_DEPS="libgtk-3-0 libcairo-gobject2 libdbus-glib-1-2 libatomic1 libxslt1.1" \
    CHROMIUM_DEPS="libsoup2.4-1 libvpx7 libevent-2.1-7 libwoff1 libharfbuzz-icu0 libgstreamer-plugins-base1.0-0 libgstreamer1.0-0 libgstreamer-gl1.0-0 libopenjp2-7 libwebpdemux2 libenchant-2-2 libsecret-1-0 libhyphen0 libmanette-0.2-0 libgles2 gstreamer1.0-libav libnss3 libnspr4" \
    TEST_DEPS="python3 python3-pip" \
    FLOW_DEPS="jq curl unzip jwm tzdata xvfb fonts-noto-cjk x11vnc xz-utils openssh-server xterm iproute2" \
    REC_DEPS="ffmpeg iputils-ping screen"
#   SERVER_DEPS="openjdk-8-jdk redis-server mysql-server nginx maven"
# RUN sed -i -E 's/archive.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list && sed -i -E 's/security.ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
EXPOSE 5900 7900
RUN apt update && \
    (echo "mysql-server-8.0 mysql-server/root_password_again password 123456" | debconf-set-selections) && \
    (echo "mysql-server-8.0 mysql-server/root_password password 123456" | debconf-set-selections) && \
    (echo "tzdata tzdata/Areas select Asia" | debconf-set-selections) && \
    (echo "tzdata tzdata/Zones/Asia select Shanghai" | debconf-set-selections) && \
    DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true apt install -y  --no-install-recommends $WEBKIT_DEPS $FIREFOX_DEPS $CHROMIUM_DEPS $TEST_DEPS $FLOW_DEPS $SERVER_DEPS && \
    apt install -y $REC_DEPS && \
    apt-get autoremove -y && \
	apt-get -qyy clean && \
  sed -i 's/BIG-REQUESTS/_IG-REQUESTS/' /usr/lib/x86_64-linux-gnu/libxcb.so.1 && \
	/bin/rm -rf /var/lib/apt /var/lib/cache /var/lib/logs
# RUN curl -skL https://mirrors.tuna.tsinghua.edu.cn/nodejs-release/v16.9.1/node-v16.9.1-linux-x64.tar.xz|unxz|tar xvf -  -C /opt
# RUN curl -skL https://nodejs.org/download/release/v16.19.1/node-v16.19.1-linux-x64.tar.xz|unxz|tar xvf -  -C /opt
RUN curl -skL https://mirrors.aliyun.com/nodejs-release/v16.19.1/node-v16.19.1-linux-x64.tar.xz|unxz|tar xvf -  -C /opt

#-i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip3 install --no-cache-dir robotframework robotframework-dependencylibrary \
                    robotframework-browser pyvirtualdisplay robotframework-pabot robotframework-seleniumlibrary \
                    requests robotframework-requests RESTinstance \
                    robotframework-databaselibrary pymysql && \
    pip3 freeze &&\
    ssh-keygen -A &&\
    echo root:password|chpasswd
COPY sshd_config /etc/ssh/sshd_config



########################################
# noVNC exposes VNC through a web page #
########################################
ENV NOVNC_VERSION="1.4.0" \
    WEBSOCKIFY_VERSION="0.11.0"
RUN curl -skL -o noVNC.zip \
       "https://github.com/novnc/noVNC/archive/refs/tags/v${NOVNC_VERSION}.zip" \
  && unzip -x noVNC.zip \
  && mkdir -p /opt/bin/ && mv noVNC-${NOVNC_VERSION} /opt/bin/noVNC \
  && cp /opt/bin/noVNC/vnc.html /opt/bin/noVNC/index.html \
  && rm noVNC.zip \
  && curl -skL -o websockify.zip \
      "https://github.com/novnc/websockify/archive/refs/tags/v${WEBSOCKIFY_VERSION}.zip" \
  && unzip -x websockify.zip \
  && rm websockify.zip \
  && rm -rf websockify-${WEBSOCKIFY_VERSION}/tests \
  && mv websockify-${WEBSOCKIFY_VERSION} /opt/bin/noVNC/utils/websockify

#==============================
# Generating the VNC password as seluser
# So the service can be started with seluser
#==============================

RUN mkdir -p ${HOME}/.vnc \
  && x11vnc -storepasswd secret ${HOME}/.vnc/passwd

RUN chmod -R 777 ${HOME} \
  && chgrp -R 0 ${HOME} \
  && chmod -R g=u ${HOME}

RUN curl -skL https://github.com/fatedier/frp/releases/download/v0.47.0/frp_0.47.0_linux_amd64.tar.gz | gunzip |tar xvf - -C /opt && sh -c '/bin/rm -rf /opt/frp_0.47.0_linux_amd64/{frps*,*.ini}'
